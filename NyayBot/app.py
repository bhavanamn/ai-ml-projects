import streamlit as st
from streamlit_chat import message
from langchain.chains import ConversationalRetrievalChain
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.llms import CTransformers
from langchain.llms import Replicate
from langchain.text_splitter import CharacterTextSplitter
from langchain.vectorstores import FAISS
from langchain.memory import ConversationBufferMemory
from langchain.document_loaders import PyPDFLoader
from langchain.document_loaders import TextLoader
from langchain.document_loaders import Docx2txtLoader
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler
import os
from dotenv import load_dotenv
import tempfile
from flask import Flask, request, jsonify
from flask_cors import CORS

load_dotenv()

chain = None

def conversation_chat(query, chain, history):
    result = chain({"question": query})
    
    return result["answer"]


def create_conversational_chain(vector_store):
    load_dotenv()
    # Create llm
    #llm = CTransformers(model="llama-2-7b-chat.ggmlv3.q4_0.bin",
                        #streaming=True, 
                        #callbacks=[StreamingStdOutCallbackHandler()],
                        #model_type="llama", config={'max_new_tokens': 500, 'temperature': 0.01})
    llm = Replicate(
        streaming = True,
        model = "replicate/llama-2-70b-chat:58d078176e02c219e11eb4da5a02a7830a283b14cf8f94537af893ccff5ee781", 
        callbacks=[StreamingStdOutCallbackHandler()],
        input = {"temperature": 0.01, "max_length" :500,"top_p":1})
    memory = ConversationBufferMemory(memory_key="chat_history", return_messages=True)

    chain = ConversationalRetrievalChain.from_llm(llm=llm, chain_type='stuff',
                                                 retriever=vector_store.as_retriever(search_kwargs={"k": 2}),
                                                 memory=memory)
    return chain


def main():
    global chain
    load_dotenv()

    # Define the folder path
    folder_path = "dataset"

    # Create the 'dataset' folder if it doesn't exist
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)

    # Get a list of all files in the 'dataset' folder
    files = os.listdir(folder_path)

    text = []
    for file_name in files:
        # Construct the full file path
        file_path = os.path.join(folder_path, file_name)
        print(file_path)
        # Check if the file exists
        if os.path.isfile(file_path):
            # Process the file
            file_extension = os.path.splitext(file_name)[1]


            loader = None
            if file_extension == ".pdf":
                loader = PyPDFLoader(file_path)
            elif file_extension == ".docx" or file_extension == ".doc":
                loader = Docx2txtLoader(file_path)
            elif file_extension == ".txt":
                loader = TextLoader(file_path)

            if loader:
                text.extend(loader.load())
        break

    text_splitter = CharacterTextSplitter(separator="\n", chunk_size=1000, chunk_overlap=100, length_function=len)
    text_chunks = text_splitter.split_documents(text)

    # Create embeddings
    embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2", 
                                        model_kwargs={'device': 'cpu'})

    # Create vector store
    vector_store = FAISS.from_documents(text_chunks, embedding=embeddings)

    # Create the chain object
    chain = create_conversational_chain(vector_store)
    print('*************8',chain)



app = Flask(__name__)
CORS(app)

@app.route('/api/ask', methods=['GET'])
def ask():
    user_input = request.args.get('question')  # Extract the question from the query parameters

    if user_input:
        output = conversation_chat(user_input, chain, None)
        
        return jsonify({'response': output})
    else:
        return jsonify({'error': 'Invalid request. Please provide a question.'}), 400

if __name__ == '__main__':
    main()
    app.run()


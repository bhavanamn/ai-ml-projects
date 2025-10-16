import streamlit as st
import joblib
import re
import string
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer
import nltk

# Download stopwords if not already done
nltk.download('stopwords')

# Load the saved models and vectorizer
models = {
    'Logistic Regression': joblib.load('logistic_regression_model.pkl'),
    'Decision Tree': joblib.load('decision_tree.pkl'),
    'Random Forest': joblib.load('random_forest_model.pkl'),
    'Naive Bayes': joblib.load('naive_bayes_model.pkl'),
    'K-Nearest Neighbors (KNN)': joblib.load('knn_model.pkl')
}

cv = joblib.load('tfidf_count_vectorizer.pkl')

# Initialize stemmer and stopwords
stemmer = PorterStemmer()
stopwords = stopwords.words('english')

# Function to clean input text (same cleaning process you used before)
def clean(text):
    text = str(text).lower()
    text = re.sub('\[.*?\]', '', text)
    text = re.sub('https?://\S+|www\.\S+', '', text)
    text = re.sub('<.*?>+', '', text)
    text = re.sub('[%s]' % re.escape(string.punctuation), '', text)
    text = re.sub('\n', '', text)
    text = re.sub('\w*\d\w*', '', text)
    text = [word for word in text.split(' ') if word not in stopwords]
    text = ' '.join(text)
    text = [stemmer.stem(word) for word in text.split(' ')]
    text = ' '.join(text)
    return text

# Streamlit UI
st.title("Hate Speech Detection")

# Dropdown for selecting model
model_choice = st.selectbox(
    "Choose a classification model:",
    ['Logistic Regression', 'Decision Tree', 'Random Forest', 'Naive Bayes', 'K-Nearest Neighbors (KNN)']
)

# Get input from user
user_input = st.text_area("Enter the tweet or text:")

# When the user clicks the button
if st.button("Classify"):
    if user_input:
        # Clean and vectorize the input
        cleaned_input = clean(user_input)
        input_vector = cv.transform([cleaned_input])
        
        # Get the selected model
        clf = models[model_choice]
        
        # Predict using the chosen model
        prediction = clf.predict(input_vector)
        
        # Display result
        if prediction == 'Hate Speech':
            st.error("This text is classified as: **Hate Speech**")
        elif prediction == 'Offensive Language':
            st.warning("This text is classified as: **Offensive Language**")
        else:
            st.success("This text is classified as: **Normal**")
    else:
        st.write("Please enter some text for classification.")

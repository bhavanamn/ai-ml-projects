import os
import sys
import numpy as np
import cv2
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QPixmap, QFont
from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QPushButton, QLabel, QLCDNumber,
    QVBoxLayout, QWidget, QFileDialog,QTableWidget, QTableWidgetItem, 
)

from scipy.ndimage import gaussian_filter
from scipy.ndimage import gaussian_filter1d
from scipy.signal import find_peaks
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.colors import LightSource
from collections import defaultdict

# from reportlab.lib.pagesizes import letter
# from reportlab.pdfgen import canvas
# from reportlab.lib.utils import ImageReader


class Window(QMainWindow):
    def __init__(self):
        super().__init__()
        self.peak_indices = []
        self.central_peak_index = None
        self.depth_y = []
        self.depth_d = []
        self.image_paths = []  # To store the paths of the selected images
        self.setGeometry(50, 50, 1500, 1100)  # Adjusted height for better visibility
        self.setWindowTitle('Flaw Detection System - Reactor Engineering Division')
        self.setStyleSheet("background-color: lightgray;")
        # new addons:
         # Central widget and layout
        central_widget = QWidget(self)
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)

         # Table to display flaw data
            # self.table_widget = QTableWidget(self)
            # layout.addWidget(self.table_widget)
            # self.table_widget.setGeometry(1000, 660, 800, 450)
        self.table_widget = QTableWidget(self)
        self.table_widget.setGeometry(1000, 660, 800, 450)  # x, y, width, heigh


        # Labels
        self.label_1 = QLabel('Flaw Detection System - Reactor Engineering Division', self)
        self.label_1.setFont(QFont('Arial', 18))
        self.label_1.setGeometry(500, 10, 600, 100)

        self.Label = QLabel(self)
        self.Label.setGeometry(50, 150, 400, 400)

        # self.Label_2 = QLabel(self)
        # self.Label_2.setGeometry(50, 500, 400, 400)

        self.label_4 = QLabel(self)
        self.label_4.setFont(QFont('Arial', 14))
        self.label_4.setGeometry(500, 150, 400, 400)

        self.label_5 = QLabel(self)
        self.label_5.setFont(QFont('Arial', 14))
        self.label_5.setGeometry(1000, 80, 800, 450)

        self.label_6 = QLabel(self)
        self.label_6.setFont(QFont('Arial', 14))
        self.label_6.setGeometry(500, 500, 400, 400)

        # self.lcdnumber = QLCDNumber(self)
        # self.lcdnumber.setGeometry(350, 910, 200, 50)

        # self.label_8 = QLabel(self)
        # self.label_8.setFont(QFont('Arial', 14))
        # self.label_8.setGeometry(1000, 660, 800, 450)

        # Buttons
        self.create_buttons()

        # Show the main window
        self.show()

    def create_buttons(self):
        self.create_button('Open Image', self.load_image, 100, 590)
        self.create_button('Processed Image', self.processed_image, 650, 590)
        self.create_button('3D GRAPH', self.graph_3d, 1300, 590)
        # self.create_button('Calculate Flaw Depth (in mm)', self.calculate_flaw_depth, 100, 900)
        # self.create_button('3D GRAPH', self.graph_3d, 100, 1000)

    def create_button(self, text, function, x, y):
        btn = QPushButton(text, self)
        btn.move(x, y)
        btn.resize(200, 50)
        btn.setStyleSheet("background-color: green; color: white;")
        btn.clicked.connect(function)
    
    def load_image(self):
        options = QFileDialog.Options()
        file_names, _ = QFileDialog.getOpenFileNames(self, "Open Image Files", "", "Images (*.png *.xpm *.jpg *.jpeg *.bmp);;All Files (*)", options=options)
        if file_names:
            self.image_paths = file_names
            self.save_selected_images()  # Save the selected images
            self.process_and_display_image()

    def save_selected_images(self):
        save_path = 'C:\\Users\\bhava\\BARC PROJECT\\New folder'  # Adjust the path as needed
        os.makedirs(save_path, exist_ok=True)

        for file_name in self.image_paths:
            try:
                image = cv2.imread(file_name)
                if image is None:
                    print(f"Error: Unable to read image '{file_name}'")
                    continue
                
                base_name = os.path.basename(file_name)
                save_file_path = os.path.join(save_path, base_name)
                cv2.imwrite(save_file_path, image)
                print(f"Saved image to '{save_file_path}'")

            except Exception as e:
                print(f"Error saving image '{file_name}': {str(e)}")

    def process_and_display_image(self):
        if not self.image_paths:
            return

        path = 'C:\\Users\\bhava\\BARC PROJECT\\New folder'  # Adjust the path as needed
        for file_name in self.image_paths:
            try:
                flawimage = cv2.imread(file_name)
                if flawimage is None:
                    print(f"Error: Unable to read image '{file_name}'")
                    continue
                
                resized_image = cv2.resize(flawimage, (400, 400))
                base_name = os.path.basename(file_name)
                resized_image_path = os.path.join(path, f'resized_{base_name}')
                cv2.imwrite(resized_image_path, resized_image)

                self.pixmap = QPixmap(resized_image_path)
                self.Label.setPixmap(self.pixmap)

            except Exception as e:
                print(f"Error processing image '{file_name}': {str(e)}")

    def processed_image(self):
        if not self.image_paths:
            return

        path = 'C:\\Users\\bhava\\BARC PROJECT\\New folder'  # Adjust the path as needed
        for image_path in self.image_paths:
            try:
                base_name = os.path.basename(image_path)
                image_1 = cv2.imread(image_path)
                if image_1 is None:
                    print(f"Error: Unable to read image '{image_path}'")
                    continue

                image_rgb_1 = cv2.cvtColor(image_1, cv2.COLOR_BGR2RGB)
                blurred_image_1 = cv2.GaussianBlur(image_rgb_1, (5, 5), 0)
                _, thresholded_image_1 = cv2.threshold(blurred_image_1, 100, 255, cv2.THRESH_BINARY)
                processed_image_path = os.path.join(path, f'processed_{base_name}')
                cv2.imwrite(processed_image_path, thresholded_image_1)

                # Corrected: Resize the processed image for display
                processed_resized_image = cv2.resize(thresholded_image_1, (400, 400))
                resized_image_path = os.path.join(path, f'resized_processed_{base_name}')
                cv2.imwrite(resized_image_path, processed_resized_image)

                self.pixmap = QPixmap(resized_image_path)
                self.label_4.setPixmap(self.pixmap)

                # self.pixmap = QPixmap(resized_image_path)
                # self.label_6.setPixmap(self.pixmap)

            except Exception as e:
                print(f"Error processing image '{image_path}': {str(e)}")
 
        

    def graph_3d(self):
        if not self.image_paths:
            return

        try:
            save_path = 'C:\\Users\\bhava\\BARC PROJECT\\New folder'  # Adjust the path as needed
            self.depth_y = []
            self.depth_d = []

            for image_path in self.image_paths:
                base_name = os.path.basename(image_path)
                selected_image_path = os.path.join(save_path, base_name)
                image = cv2.imread(selected_image_path)
                if image is None:
                    print(f"Error: Unable to read image '{selected_image_path}'")
                    continue

                # Convert to RGB
                image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

                # Apply Gaussian blur
                blurred_image = cv2.GaussianBlur(image_rgb, (5, 5), 0)

                # Apply thresholding
                _, thresholded_image = cv2.threshold(blurred_image, 100, 255, cv2.THRESH_BINARY)
                H, W, _ = thresholded_image.shape

                for y in range(H):
                    image_slice = thresholded_image[y, :, 0]
                    smooth_curve = gaussian_filter1d(image_slice, sigma=5)
                    self.depth_indices, self.depth_properties = find_peaks(smooth_curve, height=1)
                    # plt.plot(np.arange(W), smooth_curve, label=f'Row {y}')
                    if len(self.depth_indices) == 2:
                        ans = self.depth_indices[-1] - self.depth_indices[0]
                        ans = (ans * 0.00286 * 10) / 5.671
                        self.depth_d.append(ans)
                    else:
                        self.depth_d.append(0)

                    self.depth_y.append(y)

            self.depth_y = np.array(self.depth_y)
            self.depth_d = np.array(self.depth_d)
            print("self depth_y array")
            print(self.depth_y)
            print("self depth_d array")
            print(self.depth_d)
            print("self depth_d shape")
            print(self.depth_d.shape)

            if len(self.depth_y) != len(self.depth_d):
                print("Mismatch in lengths of depth_y and depth_d arrays.")
                return
            self.plot_3d_graph(thresholded_image)

            # plt.show()

        except Exception as e:
            print(f"Error plotting 3D graph: {str(e)}")
    
    
    def plot_3d_graph(self, thresholded_image):
        try:
            path = 'C:\\Users\\bhava\\BARC PROJECT\\New folder'  # Adjust the path as needed
            os.makedirs(path, exist_ok=True)

            if thresholded_image is None or len(thresholded_image.shape) != 3:
                raise ValueError("Invalid thresholded_image input")

            H, W, _ = thresholded_image.shape
            pixel_to_mm = 0.00286

            X_mm, Y_mm = np.meshgrid(np.arange(W) * pixel_to_mm, np.arange(H) * pixel_to_mm)
            Z = np.zeros_like(X_mm)

            for i, y in enumerate(self.depth_y):
                if y < H:
                    Z[y, :] = self.depth_d[i]
            def detect_peak_boundaries(data, peaks, threshold):
                boundaries = []
                for peak in peaks:
                    # Find the start point
                    start = peak
                    while start > 0 and data[start] > threshold:
                        start -= 1
                    # Find the end point
                    end = peak
                    while end < len(data) and data[end] > threshold:
                        end += 1
                    boundaries.append((start, end))
                return boundaries

            # Surface plot
            fig = plt.figure()
            ax = fig.add_subplot(111, projection='3d')
            surf = ax.plot_surface(X_mm, Y_mm, Z, cmap='viridis', edgecolor='none', linewidth=0, antialiased=True)
            fig.colorbar(surf, shrink=0.5, aspect=5).set_label('Depth (mm)')
            ax.set_xlabel('X (mm)')
            ax.set_ylabel('Y (mm)')
            ax.set_zlabel('Depth (mm)')
            ax.set_title('3D Surface Plot')
            surface_plot_path = os.path.join(path, '3d_surfacedup.png')
            plt.savefig(surface_plot_path)
            plt.savefig(os.path.join(path, '3d_surface.png'))
           
            self.pixmap = QPixmap(os.path.join(path, '3d_surface.png'))
            self.label_5.setPixmap(self.pixmap)
            plt.show()

            # 2D Plot (Original)
            plt.figure(figsize=(8, 6))
            plt.plot(Y_mm[:, 0], Z[:, 0], label='Original Curve', color='blue')
            plt.xlabel('Y (mm)')
            plt.ylabel('Depth (mm)')
            plt.title('2D Plot (Original)')
            plt.grid(True)
            plt.legend()
            plt.savefig(os.path.join(path, '2d_plot_original.png'))
            original_plot_path = os.path.join(path, '2d_plot_original.png')
            plt.savefig(original_plot_path)
            plt.show()

            # Apply Gaussian smoothing to Z
            # Z_smooth = gaussian_filter(Z, sigma=3.0)
            # Z_smooth_1 = gaussian_filter(Z,sigma = 7.0)
            Z_smooth_1 = gaussian_filter(Z,sigma = 13.0)

            

            # 2D Plot (Smoothed)
            plt.figure(figsize=(8, 6))
            plt.plot(Y_mm[:, 0], Z_smooth_1[:, 0], label='Smoothed Curve', color='orange')
            plt.xlabel('Y (mm)')
            plt.ylabel('Depth (mm)')
            plt.title('2D Plot (Smoothed) with more smoothening')
            plt.grid(True)
            plt.legend()
            plt.savefig(os.path.join(path, '2d_plot_smoothed1.png'))
            smoothed_plot_path = os.path.join(path, '2d_plot_smoothed.png')
            plt.savefig(smoothed_plot_path)
            plt.show()


            

            # find peaks in smoothed curve(Z_smooth)
            peaks_smooth1,_ = find_peaks(Z_smooth_1[:,0] ,height = 0)
            num_peaks_smooth1 = len(peaks_smooth1)
            print(f'Number of peaks in smoothed_1 curve:{num_peaks_smooth1}')


            ######################
            





            #####################

            # Find peaks in smoothed curve (Z_smooth)
            # peaks_smooth, _ = find_peaks(Z_smooth[:, 0], height=0)
            # num_peaks_smooth = len(peaks_smooth)
            # print(f"Number of peaks in smoothed curve: {num_peaks_smooth}")

            # Find peaks in original curve (Z)
            # peaks_original, _ = find_peaks(Z[:, 0], height=0)
            # num_peaks_original = len(peaks_original)
            # print(f"Number of peaks in original curve: {num_peaks_original}")

            peak_boundaries = detect_peak_boundaries(Z_smooth_1[:, 0], peaks_smooth1, threshold=0.5)
            # print("Flaw boundaries in smoothed curve(in pixels):")
            # for i, (start, end) in enumerate(peak_boundaries):
            #     print(f"Peak {i+1}: Start index {start}, End index {end}")

            self.table_widget.setRowCount(len(peak_boundaries))
            self.table_widget.setColumnCount(4)
            self.table_widget.setHorizontalHeaderLabels(["Flaw", "Start (mm)", "End (mm)", "Average Depth (mm)"])

            
            
            
            
            
            
            
            # pdf_path = os.path.join(path, 'flaw_report.pdf')
            # c = canvas.Canvas(pdf_path, pagesize=letter)
            # c.drawString(200, 750, "Flaw Detection Report")
            # c.drawString(200, 730, "----------------------------")
            # y_position = 700


            # Append plots to the PDF
            # surface_plot = ImageReader(surface_plot_path)
            # original_plot = ImageReader(original_plot_path)
            # smoothed_plot = ImageReader(smoothed_plot_path)
            # image_width, image_height = 300, 300
            # c.drawImage(surface_plot, 100, y_position-image_height-50, width=image_width, height=image_height)
            # y_position -= (image_height + 50)
            # if y_position < 50:  # Create a new page if the current page is full
            #         c.showPage()
            #         y_position = 750
            # c.drawImage(original_plot, 100, y_position-image_height-50, width=image_width, height=image_height)
            # y_position -= (image_height + 50)
            # if y_position < 50:  # Create a new page if the current page is full
            #         c.showPage()
            #         y_position = 750
            # c.drawImage(smoothed_plot, 100, y_position-image_height-50, width=image_width, height=image_height)
            # y_position -= (image_height + 50)  # Adjust for space

            # print("Flaw boundaries in smoothed curve (in mm):")

            flaw_data = []
            # Append table to the PDF
            # c.drawString(100, y_position, "Flaw Data Table")
            # y_position -= 20
            # table_headers = ["Flaw", "Start (mm)", "End (mm)", "Average Depth (mm)"]
            # col_width = 100

            # # Draw headers
            # for col_num, header in enumerate(table_headers):
            #     c.drawString(100 + col_num * col_width, y_position, header)
            # y_position -= 20

           

            for i, (start, end) in enumerate(peak_boundaries):
                start_mm = start * pixel_to_mm
                end_mm = end * pixel_to_mm

                # Adjust end_idx if start_idx equals end_idx
                start_idx = int(start_mm / pixel_to_mm)
                end_idx = int(end_mm / pixel_to_mm)
                
                if start_idx == end_idx:
                    end_mm = end_mm+0.1
                    end_idx = int(end_mm / pixel_to_mm)  
                    
                      # Increment end_idx by 0.1 mm

                # Calculate average depth within the adjusted range
                average_depth = np.nanmean(Z[start_idx:end_idx, 0])
                print(f"Flaw {i+1}: Start {start_mm:.7f} mm, End {end_mm:.7f} mm")
                print(f"Average Depth of Flaw {i+1}: {average_depth:.7f} mm")

                flaw_data.append((f"Flaw {i+1}", f"{start_mm:.7f}", f"{end_mm:.7f}", f"{average_depth:.7f}"))

                # Draw rows in PDF
                # for row in flaw_data:
                #     for col_num, item in enumerate(row):
                #         c.drawString(100 + col_num * col_width, y_position, item)
                #     y_position -= 20
                #     if y_position < 100:  # Create a new page if the current page is full
                #         c.showPage()
                #         y_position = 750
                #         c.drawString(100, y_position, "Flaw Data Table (continued)")
                #         y_position -= 20

                # Set table items in GUI
                self.table_widget.setItem(i, 0, QTableWidgetItem(f"Flaw {i+1}"))
                self.table_widget.setItem(i, 1, QTableWidgetItem(f"{start_mm:.7f}"))
                self.table_widget.setItem(i, 2, QTableWidgetItem(f"{end_mm:.7f}"))
                self.table_widget.setItem(i, 3, QTableWidgetItem(f"{average_depth:.7f}"))

            # Save the PDF
            # c.save()




        except Exception as e:
            print(f"Error plotting 3D graph: {str(e)}")

    




def run():
    app = QApplication(sys.argv)
    gui = Window()
    sys.exit(app.exec_())

if __name__ == "__main__":
    run()
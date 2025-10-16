import sys
from PyQt5.QtWidgets import QApplication, QDialog, QLineEdit, QVBoxLayout, QPushButton, QLabel

class LoginDialog(QDialog):
    def __init__(self):
        super().__init__()
        self.setWindowTitle('Login')
        self.setFixedSize(300, 200)

        layout = QVBoxLayout()

        self.username_label = QLabel('Username:')
        self.username_input = QLineEdit()

        self.password_label = QLabel('Password:')
        self.password_input = QLineEdit()
        self.password_input.setEchoMode(QLineEdit.Password)

        self.login_button = QPushButton('Login')
        self.login_button.clicked.connect(self.check_credentials)

        layout.addWidget(self.username_label)
        layout.addWidget(self.username_input)
        layout.addWidget(self.password_label)
        layout.addWidget(self.password_input)
        layout.addWidget(self.login_button)

        self.setLayout(layout)

    def check_credentials(self):
        username = self.username_input.text()
        password = self.password_input.text()
        # Add your authentication logic here
        if username == 'admin' and password == 'password':
            self.accept()
        elif username == 'bhavana' and password == 'BHAVANA':
            self.accept()
        elif username == 'roshini' and password == '@BARCROSHINI':
            self.accept()
        else:
            error_label = QLabel('Invalid credentials', self)
            error_label.move(10, 150)
            error_label.show()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    login = LoginDialog()
    if login.exec_() == QDialog.Accepted:
        print("Logged in successfully!")
    sys.exit(app.exec_())

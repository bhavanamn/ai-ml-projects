import sys
from PyQt5.QtWidgets import QApplication
from login_dialog import LoginDialog
from flaw_detection_system import Window  # Import your Window class from the main flaw detection system code
from PyQt5.QtWidgets import QDialog

def run():
    app = QApplication(sys.argv)
    login = LoginDialog()
    if login.exec_() == QDialog.Accepted:
        gui = Window()
        gui.show()
        sys.exit(app.exec_())

if __name__ == "__main__":
    run()

import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from dotenv import load_dotenv

load_dotenv()

class EmailService:
    @staticmethod
    def send_verification_code(target_email: str, code: str):
        sender_email = os.getenv("EMAIL_USER")
        sender_password = os.getenv("EMAIL_PASSWORD")
        smtp_server = os.getenv("EMAIL_HOST", "smtp.gmail.com")
        smtp_port = int(os.getenv("EMAIL_PORT", 587))

        message = MIMEMultipart("alternative")
        message["Subject"] = "CODE D'ACCÈS MAPADY"
        message["From"] = f"MapAdy HQ <{sender_email}>"
        message["To"] = target_email

        html = f"""
        <html>
        <body style="background-color: #131318; color: #ffffff; font-family: sans-serif; padding: 20px;">
            <div style="border: 2px solid #00F0FF; padding: 20px; border-radius: 15px; text-align: center;">
                <h1 style="color: #00F0FF;">IDENTIFICATION REQUISE</h1>
                <p style="font-size: 16px;">Agent, voici votre code de vérification pour modifier vos accès :</p>
                <div style="background-color: #1a1a20; padding: 15px; border-radius: 10px; margin: 20px 0;">
                    <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #FFACE8;">{code}</span>
                </div>
                <p style="color: #666666; font-size: 12px;">Si vous n'êtes pas à l'origine de cette demande, ignorez ce message. Votre sécurité est notre priorité.</p>
            </div>
        </body>
        </html>
        """

        part = MIMEText(html, "html")
        message.attach(part)

        try:
            with smtplib.SMTP(smtp_server, smtp_port) as server:
                server.starttls()
                server.login(sender_email, sender_password)
                server.sendmail(sender_email, target_email, message.as_string())
            return True
        except Exception as e:
            print(f"Erreur d'envoi email : {e}")
            return False

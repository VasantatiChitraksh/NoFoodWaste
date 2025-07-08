import smtplib
from email.message import EmailMessage
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

EMAIL_HOST = os.getenv("EMAIL_HOST")
EMAIL_PORT = os.getenv("EMAIL_PORT")
EMAIL_ADDRESS = os.getenv("EMAIL_ADDRESS")
EMAIL_PASSWORD = os.getenv("EMAIL_PASSWORD")

async def send_email(to: str, subject: str, body: str):
    if not all([EMAIL_HOST, EMAIL_PORT, EMAIL_ADDRESS, EMAIL_PASSWORD]):
        raise ValueError("Email configuration missing in environment variables.")

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = EMAIL_ADDRESS
    msg["To"] = to
    msg.set_content(body)
    
    try:
        print(f"Attempting to send email to {to} with subject: {subject}")
        print(f"Using SMTP server: {EMAIL_HOST}:{EMAIL_PORT}")
        
        with smtplib.SMTP(EMAIL_HOST, int(EMAIL_PORT)) as server:
            server.starttls()
            print("STARTTLS enabled successfully")
            
            # Try to login
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            print("SMTP login successful")
            
            # Send the email
            server.send_message(msg)
            print(f"Email sent successfully to {to}")
            
    except smtplib.SMTPAuthenticationError as e:
        error_msg = f"SMTP Authentication failed for {EMAIL_ADDRESS}. This usually means:\n"
        error_msg += "1. For Gmail: You need to use an App Password instead of your regular password\n"
        error_msg += "2. Enable 2-factor authentication on your Gmail account\n"
        error_msg += "3. Generate an App Password in Google Account settings\n"
        error_msg += f"Original error: {str(e)}"
        print(f"Authentication Error: {error_msg}")
        raise RuntimeError(error_msg)
        
    except smtplib.SMTPConnectError as e:
        error_msg = f"Failed to connect to SMTP server {EMAIL_HOST}:{EMAIL_PORT}. Check your network connection and SMTP settings. Error: {str(e)}"
        print(f"Connection Error: {error_msg}")
        raise RuntimeError(error_msg)
        
    except smtplib.SMTPRecipientsRefused as e:
        error_msg = f"SMTP server refused recipient {to}. Check if the email address is valid. Error: {str(e)}"
        print(f"Recipient Error: {error_msg}")
        raise RuntimeError(error_msg)
        
    except Exception as e:
        error_msg = f"Failed to send email to {to}: {str(e)}"
        print(f"General Error: {error_msg}")
        raise RuntimeError(error_msg)

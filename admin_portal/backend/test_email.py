"""
Simple email test script to debug email configuration issues
"""
import asyncio
import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.email_sender import send_email

async def test_email_config():
    print("Testing email configuration...")
    print("=" * 50)
    
    # Test email address (you can change this)
    test_email = "anupamkumarpaul2005@gmail.com"
    
    try:
        await send_email(
            to=test_email,
            subject="Email Configuration Test",
            body="""
Hello!

This is a test email to verify that the email configuration is working correctly.

If you receive this email, the SMTP setup is functioning properly.

Best regards,
No Food Waste Admin Portal
            """
        )
        print("✅ Email test SUCCESSFUL!")
        print(f"Test email sent to: {test_email}")
        
    except Exception as e:
        print("❌ Email test FAILED!")
        print(f"Error: {str(e)}")
        print("\nTroubleshooting steps:")
        print("1. For Gmail, enable 2-factor authentication")
        print("2. Generate an App Password in Google Account settings")
        print("3. Replace EMAIL_PASSWORD in .env with the App Password")
        print("4. Make sure EMAIL_ADDRESS is correct")

if __name__ == "__main__":
    asyncio.run(test_email_config())

#!/usr/bin/python3.6

from sys import argv
from smtplib import SMTP_SSL
from email.mime.text import MIMEText
from email.header import Header
from email.utils import formataddr


def main(receiver,title,body):


    smtp_server = "smtp.qq.com"
    smtp_port = 465


    mail_title = title
    mail_body = body

    # 1.Create smtp
    SmtpObj = SMTP_SSL()
    SmtpObj.connect(smtp_server, smtp_port)
    SmtpObj.login(sender, sender_passwd)  # Your_password为你的授权码，邮箱是你自己的！！


    # 2.Gou zao Email content
    msg = MIMEText(mail_body,_subtype="plain")
    msg["Subject"] = mail_title

    # format

    msg["From"] = formataddr((Header(sender, "utf-8").encode(), sender))
    msg["To"] = receiver

    try:
        SmtpObj.sendmail(msg["From"], msg["To"], msg.as_string())
    #     print("Send successfully")
    except smtplib.SMTPException:
    #    print("Send Failed...")
        pass
    finally:
        SmtpObj.quit()



if __name__ == '__main__':

    # 配置变量
    sender = '发件人'
    sender_passwd = "发件人密码，一般为授权码"
    receiver = '收件人'

    main(argv[1],argv[2],argv[3])


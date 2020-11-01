#!/usr/bin/env python
#encoding=utf-8

import os
import sys
import re
import subprocess
import commands
import smtplib
import email
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
import time


def fayoujian(wenjian):
    msg=MIMEMultipart()
    msg['Subject']=os.path.splitext(os.path.basename(wenjian))[0].replace('[01]','')
    msg['From']="my_mp3@m1.sg"
    msg['To']="zouj2003@qq.com"

    # 构造MIMEText对象做为邮件显示内容并附加到根容器  
    text_msg = MIMEText("Enjoy the mp3.")
    msg.attach(text_msg)

    contype = 'application/octet-stream'
    maintype, subtype = contype.split('/', 1)

    ## 读入文件内容并格式化  
    data = open(wenjian,'rb')
    file_msg = MIMEBase(maintype, subtype)
    file_msg.set_payload(data.read( ))
    data.close( )
    email.Encoders.encode_base64(file_msg)

    ## 设置附件头  
    basename = os.path.basename(wenjian).replace('[01]','').decode('utf8').encode('gbk',"ignore")
    file_msg.add_header('Content-Disposition','attachment', filename = basename)
    msg.attach(file_msg)


    tolist=["zouj2003@qq.com"]
    s=smtplib.SMTP('127.0.0.1')
    s.sendmail("my_mp3@m1.sg",tolist,msg.as_string())
    s.quit()

if __name__=="__main__":
    wangzhi=sys.argv[1]
    tmpfolder=time.strftime("%Y%m%d_%H%M%S")
    subprocess.check_call('mkdir /root/py/createmp3/rawfile/%s'%tmpfolder,shell=True)
    os.chdir('/root/py/createmp3/rawfile/%s'%tmpfolder)

    try:
        subprocess.check_call('/root/you-get/you-get -n --no-caption "%s"'%wangzhi,shell=True)
#        subprocess.check_call(['/root/you-get/you-get','-n','--no-caption','%s'%wangzhi],timeout=100)

        print "The file be downloaded, please wait for the email."
    except:
        print "The file can not download. Try another one."
        os.chdir('/root/py/createmp3/rawfile')
        subprocess.check_call('rm -rf /root/py/createmp3/rawfile/%s'%tmpfolder,shell=True)
        exit()

    for i in os.listdir('/root/py/createmp3/rawfile/%s'%tmpfolder):
        if re.search('\[00\]',i):
            continue
        else:
            wenjianminggen=re.sub('\xe299ab','',os.path.splitext(i)[0].replace('?','').replace('"','').replace('\'','').replace('\\','').replace('\/','').replace('\:','').replace('*','').replace('<','').replace('>','').replace('郭文','gg'))
            subprocess.check_call('ffmpeg -i \'%s\' -ar 12000 -vol 256 \'%s.mp3\''%(i,wenjianminggen),shell=True)
            print wenjianminggen
            fayoujian('%s.mp3'%wenjianminggen)
            time.sleep(3)
            os.chdir('/root/py/createmp3/rawfile')
            subprocess.check_call('rm -rf /root/py/createmp3/rawfile/%s'%tmpfolder,shell=True)


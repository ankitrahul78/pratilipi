sudo yum update -y
sudo amazon-linux-extras install nginx1
sudo systemctl start nginx
sudo yum install python3-pip -y
sudo yum install git -y
sudo pip3 install boto3
sudo pip3 install flask
sudo pip3 install flask_restful
sudo pip3 install pandas
sudo pip3 install requests
git clone https://github.com/ankitrahul78/asssign-pratilipi.git
git checkout master
cd asssign-pratilipi/
# python3 main.py
chmod +x main.py
nohup python3 main.py &
sudo cp nginx.conf /etc/nginx/conf.d/
sudo systemctl restart nginx
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm

provider "aws" {
  region  = "ap-south-1"
  alias   = "secondary"
}

# Generate or use an existing key pair
resource "aws_key_pair" "my_key" {
  key_name   = "terraform-key"
  public_key = file("~/.ssh/id_ed25519.pub")  # Use your existing public key
}

# Create Security Group for EC2
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH, HTTP, and MySQL"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow MySQL from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch the EC2 instance with necessary configuration and user data
resource "aws_instance" "web_server" {
  ami           = "ami-002bb4b9277863c18"  # Change to the correct Ubuntu AMI ID for your region
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name  # Use the key pair created above
  security_groups = [aws_security_group.web_sg.name]

  # User Data to setup Apache, PHP, MySQL, WordPress, Node.js, and Git
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y && sudo apt upgrade -y

    # Install Apache, PHP, MySQL, and other dependencies
    sudo apt install -y apache2 php php-mysql mysql-server nodejs git curl

    # Start and enable Apache and MySQL services
    sudo systemctl start apache2
    sudo systemctl enable apache2
    sudo systemctl start mysql
    sudo systemctl enable mysql

    # Secure MySQL (default options)
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY 'rootpassword';"
    
    # Install WordPress
    cd /var/www/html
    sudo wget https://wordpress.org/latest.tar.gz
    sudo tar -xvzf latest.tar.gz
    sudo chown -R www-data:www-data /var/www/html/wordpress
    sudo chmod -R 755 /var/www/html/wordpress

    # Enable HTTP and MySQL in firewall
    sudo ufw allow 80/tcp
    sudo ufw allow 3306/tcp
    sudo ufw reload

    # Restart Apache to apply changes
    sudo systemctl restart apache2

    # Finished
    echo "EC2 Setup Complete"
  EOF

  tags = {
    Name = "Terraform-Test-EC2"
  }

  # Optionally associate Elastic IP after instance is running
  associate_public_ip_address = true
}

# Allocate and associate Elastic IP to EC2 instance
resource "aws_eip" "web_server_eip" {
  instance = aws_instance.web_server.id
}

# Output the public IP for easy access
output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
}


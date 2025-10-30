# DevOps Midterm Project - Configuration & Automation

This directory contains configuration files and automation scripts for the DevOps midterm project.

## Files Overview

### 1. `config.yml` - Application Configuration
YAML configuration file containing:
- Application settings (name, version, environment)
- Server configuration (host, port, timeout)
- Database connection settings
- Logging configuration
- Security settings (CORS, rate limiting)
- API endpoints configuration
- Monitoring settings
- Git repository settings

### 2. `sample-users.json` - Sample User Data
JSON file containing sample user data with the following structure:
```json
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "created_at": "2024-01-15T10:30:00Z",
    "status": "active"
  }
]
```

### 3. Git Auto-Deployment Configuration

#### Option A: SystemD Service (Recommended)
- `git-clone.service` - SystemD service unit file
- `git-clone-devops.sh` - Bash script for Git operations

#### Option B: rc.local (Legacy)
- `rc.local` - Script for legacy systems using rc.local

## Installation Instructions

### Step 1: Copy Configuration Files

```bash
# Copy config file to your application directory
cp config.yml /path/to/your/app/

# Copy sample data (optional)
cp sample-users.json /path/to/your/app/data/
```

### Step 2: Choose Auto-Deployment Method

#### Method A: SystemD Service (Modern Linux)

1. Copy the service file:
```bash
sudo cp git-clone.service /etc/systemd/system/
```

2. Copy and make the script executable:
```bash
sudo cp git-clone-devops.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/git-clone-devops.sh
```

3. Edit the repository URL in the script:
```bash
sudo nano /usr/local/bin/git-clone-devops.sh
# Change REPO_URL to your actual Git repository URL
```

4. Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable git-clone.service
sudo systemctl start git-clone.service
```

5. Check status:
```bash
sudo systemctl status git-clone.service
```

#### Method B: rc.local (Legacy Systems)

1. Copy the script to a system location:
```bash
sudo cp git-clone-devops.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/git-clone-devops.sh
```

2. Edit rc.local:
```bash
sudo cp rc.local /etc/rc.local
sudo chmod +x /etc/rc.local
```

3. Or add to existing /etc/rc.local before `exit 0`:
```bash
sudo nano /etc/rc.local
# Add: bash /usr/local/bin/git-clone-devops.sh
```

### Step 3: Configure Git Repository

Before deploying, update the repository URL in the scripts:

```bash
# In git-clone-devops.sh
REPO_URL="https://github.com/your-username/your-repo.git"
BRANCH="main"  # or your preferred branch
PROJECT_DIR="/opt/your-project"  # deployment directory
```

### Step 4: Test the Setup

1. Test the Git clone script manually:
```bash
sudo bash /usr/local/bin/git-clone-devops.sh
```

2. Check logs:
```bash
tail -f /var/log/git-clone.log
```

## Configuration Usage

### In Your Node.js Application

Load the YAML config using a library like `js-yaml`:

```javascript
const yaml = require('js-yaml');
const fs = require('fs');

try {
  const config = yaml.load(fs.readFileSync('./config.yml', 'utf8'));
  console.log(config.database.host); // Access config values
} catch (e) {
  console.error('Error loading config:', e);
}
```

### Environment Variables Override

You can override config values with environment variables:

```bash
export APP_PORT=4000
export DB_HOST=localhost
export NODE_ENV=production
```

## Troubleshooting

### Common Issues:

1. **Permission Denied**: Make sure scripts are executable and user has proper permissions
2. **Git Authentication**: For private repositories, configure SSH keys or tokens
3. **Network Issues**: Ensure the server can reach the Git repository
4. **Directory Permissions**: Check that the deployment directory has correct permissions

### Logs Location:
- Git clone operations: `/var/log/git-clone.log`
- SystemD service: `journalctl -u git-clone.service`
- rc.local: `/var/log/rc.local.log`

## Security Notes

- Store sensitive data (passwords, tokens) in environment variables
- Use SSH keys for Git authentication instead of passwords
- Regularly update dependencies and monitor logs
- Consider using Docker for better isolation

import urllib.request

url = 'http://127.0.0.1:8000/'
with urllib.request.urlopen(url, timeout=10) as f:
    html = f.read().decode('utf-8', errors='ignore')
print('FOUND_PASSWORD' if 'upload-password' in html else 'NO_PASSWORD')
print('FOUND_UPLOAD_FORM' if 'unlock-upload' in html else 'NO_UPLOAD')

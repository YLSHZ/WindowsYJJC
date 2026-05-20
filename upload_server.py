import json
import os
import shutil
import urllib.parse
from http.server import HTTPServer, SimpleHTTPRequestHandler

PORT = 8000
UPLOAD_PASSWORD = "admin123"  # 请根据需要修改为你自己的密码


def safe_filename(filename):
    filename = os.path.basename(filename)
    filename = filename.replace("\x00", "")
    return filename


class UploadHTTPRequestHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/upload':
            self.send_response(302)
            self.send_header('Location', '/')
            self.end_headers()
            return

        if self.path == '/files.json':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.end_headers()

            files = []
            for name in sorted(os.listdir('.'), key=str.lower):
                if name in ('index.html', os.path.basename(__file__)):
                    continue
                if name.startswith('.') or not os.path.isfile(name):
                    continue
                files.append({
                    'name': name,
                    'path': urllib.parse.quote(name, safe='')
                })

            self.wfile.write(json.dumps(files, ensure_ascii=False).encode('utf-8'))
            return

        return super().do_GET()

    def do_POST(self):
        if self.path != '/upload':
            self.send_error(404, 'Not Found')
            return

        content_type = self.headers.get('Content-Type', '')
        if 'multipart/form-data' not in content_type:
            self.send_error(400, 'Bad Request: Expected multipart/form-data')
            return

        length = int(self.headers.get('Content-Length', 0))
        if length <= 0:
            self.send_error(400, 'Bad Request: Missing Content-Length')
            return

        boundary = None
        for part in content_type.split(';'):
            part = part.strip()
            if part.startswith('boundary='):
                boundary = part.split('=', 1)[1]
                break

        if not boundary:
            self.send_error(400, 'Bad Request: Missing boundary')
            return

        if boundary.startswith('"') and boundary.endswith('"'):
            boundary = boundary[1:-1]

        data = self.rfile.read(length)
        boundary_bytes = ('--' + boundary).encode('utf-8')
        parts = data.split(boundary_bytes)

        password = None
        file_info = None

        for part in parts:
            part = part.strip(b'\r\n')
            if not part or part == b'--':
                continue

            header_block, _, body = part.partition(b'\r\n\r\n')
            if not body:
                continue

            headers = {}
            for line in header_block.split(b'\r\n'):
                if b':' in line:
                    name, value = line.split(b':', 1)
                    headers[name.decode('utf-8').strip().lower()] = value.decode('utf-8').strip()

            disposition = headers.get('content-disposition', '')
            if 'name="password"' in disposition:
                password = body.decode('utf-8').strip().rstrip('--')
            elif 'name="file"' in disposition:
                filename = None
                for item in disposition.split(';'):
                    item = item.strip()
                    if item.startswith('filename='):
                        filename = item.split('=', 1)[1].strip('"')
                        break
                if filename:
                    content = body.rstrip(b'\r\n')
                    file_info = {
                        'filename': filename,
                        'content': content
                    }

        if password != UPLOAD_PASSWORD:
            self.send_response(403)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write('<html><body><h2>密码错误，上传失败。</h2><p><a href="/">返回首页</a></p></body></html>'.encode('utf-8'))
            return

        if not file_info:
            self.send_response(400)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write('<html><body><h2>未选择文件。</h2><p><a href="/">返回首页</a></p></body></html>'.encode('utf-8'))
            return

        filename = safe_filename(file_info['filename'])
        if not filename:
            self.send_response(400)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write('<html><body><h2>无效文件名。</h2><p><a href="/">返回首页</a></p></body></html>'.encode('utf-8'))
            return

        save_path = os.path.join(os.getcwd(), filename)
        base, ext = os.path.splitext(filename)
        counter = 1
        while os.path.exists(save_path):
            filename = f"{base}_{counter}{ext}"
            save_path = os.path.join(os.getcwd(), filename)
            counter += 1

        try:
            with open(save_path, 'wb') as output_file:
                output_file.write(file_info['content'])
        except Exception as error:
            self.send_response(500)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write(f'<html><body><h2>保存文件失败：{error}</h2><p><a href="/">返回首页</a></p></body></html>'.encode('utf-8'))
            return

        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(f'<html><body><h2>上传成功：{filename}</h2><p><a href="/">返回首页</a></p></body></html>'.encode('utf-8'))


if __name__ == '__main__':
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    server_address = ('0.0.0.0', PORT)
    httpd = HTTPServer(server_address, UploadHTTPRequestHandler)
    print(f'上传服务器已启动，访问 http://127.0.0.1:{PORT}')
    print('密码上传地址：/upload, 上传密码已在 upload_server.py 中设置')
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print('\n服务器停止')
        httpd.server_close()

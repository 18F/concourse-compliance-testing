import tinys3
import os
import glob


key = os.environ.get('S3_ACCESS_KEY', '')
secret = os.environ.get('S3_SECRET_KEY', '')
bucket = os.environ.get('S3_BUCKET', '')
path = 'results/'

conn = tinys3.Connection(key, secret, default_bucket=bucket)

for infile in glob.glob(os.path.join(path, '*.json')):
    result_file = open(infile, 'rb')
    conn.upload(infile, result_file)


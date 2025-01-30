import json
import sqlite3
import boto3
import os

# Simulate AWS S3 locally (you can replace this with actual AWS credentials)
class FakeS3:
    def put_object(self, Bucket, Key, Body, ContentType):
        with open(Key, "w") as f:
            f.write(Body)
        print(f"Fake upload: {Key} saved locally")

# Use fake S3 for local testing
s3 = FakeS3()

# SQLite database file (local)
DB_FILE = "test.db"
S3_BUCKET = "fake-bucket"  # Not used in local mode

def setup_fake_db():
    """Create a fake SQLite database with test data."""
    connection = sqlite3.connect(DB_FILE)
    cursor = connection.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS documents (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT
        )
    """)
    
    cursor.execute("DELETE FROM documents")  # Clear old data
    sample_data = [
        ("Doc 1", "This is the content of document 1."),
        ("Doc 2", "Another sample document with test data."),
        ("Doc 3", "More RAG-related fake content."),
    ]
    cursor.executemany("INSERT INTO documents (title, content) VALUES (?, ?)", sample_data)
    
    connection.commit()
    connection.close()

def fetch_data_from_sqlite():
    """Fetch data from SQLite (simulating MySQL behavior)."""
    connection = sqlite3.connect(DB_FILE)
    cursor = connection.cursor()
    
    cursor.execute("SELECT * FROM documents")
    rows = cursor.fetchall()
    
    # Convert to dict format similar to MySQL
    data = [{"id": row[0], "title": row[1], "content": row[2]} for row in rows]

    connection.close()
    return data

def upload_to_s3(data, filename):
    """Convert data to JSON and simulate upload to S3."""
    json_data = json.dumps(data, indent=2)
    s3.put_object(Bucket=S3_BUCKET, Key=filename, Body=json_data, ContentType="application/json")
    print(f"Data saved to {filename} (simulating S3 upload)")

def lambda_handler(event=None, context=None):
    """AWS Lambda handler function (for local testing)."""
    print("Setting up fake database...")
    setup_fake_db()  # Create test data

    print("Fetching data from SQLite...")
    data = fetch_data_from_sqlite()

    if not data:
        print("No data found.")
        return {"status": "No data found"}

    filename = "rag-data.json"
    print("Uploading data to fake S3...")
    upload_to_s3(data, filename)

    return {"status": "Success", "local_file": filename}

# Run locally
if __name__ == "__main__":
    response = lambda_handler()
    print(response)

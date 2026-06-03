import urllib.request
import urllib.error
import json
import uuid
import time
import os
import glob

url = "https://fjbwuzqberpkzpaukauq.supabase.co"
anon_key = "sb_publishable_LP6HLynRHTDgEX_TxcvEEQ_Ywd85-GQ"
bucket = "rsms-uploads"
artifact_dir = "/Users/chetankandpal/.gemini/antigravity/brain/a359bfe0-8868-4820-b2a5-9ad84d7c4b35"

# 1. Authenticate
auth_data = {
    "email": "admin@gmail.com",
    "password": "Admin@123"
}
headers = {
    "apikey": anon_key,
    "Content-Type": "application/json"
}
req = urllib.request.Request(f"{url}/auth/v1/token?grant_type=password", data=json.dumps(auth_data).encode('utf-8'), headers=headers, method='POST')
try:
    with urllib.request.urlopen(req) as response:
        res_data = json.loads(response.read().decode('utf-8'))
        access_token = res_data.get("access_token")
        print("Authenticated successfully.")
except Exception as e:
    print("Authentication failed:", e)
    exit(1)

db_headers = {
    "apikey": anon_key,
    "Authorization": f"Bearer {access_token}",
    "Content-Type": "application/json"
}

# 2. Fetch all products
print("Fetching all products...")
fetch_req = urllib.request.Request(f"{url}/rest/v1/catalogs?select=id,catalog_id,product_images", headers=db_headers, method='GET')
try:
    with urllib.request.urlopen(fetch_req) as fetch_res:
        catalogs = json.loads(fetch_res.read().decode('utf-8'))
except Exception as e:
    print("Failed to fetch catalogs:", e)
    exit(1)

# Helper function to upload image
def upload_image(local_pattern):
    search_path = os.path.join(artifact_dir, local_pattern)
    matched_files = glob.glob(search_path)
    if not matched_files:
        print(f"No file found matching pattern {local_pattern}")
        return None
    # Use the most recent file
    file_path = max(matched_files, key=os.path.getmtime)
    file_name = os.path.basename(file_path)
    
    remote_filename = f"{uuid.uuid4()}-{int(time.time())}.png"
    remote_path = f"catalogs/{remote_filename}"
    upload_url = f"{url}/storage/v1/object/{bucket}/{remote_path}"
    
    upload_headers = {
        "apikey": anon_key,
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "image/png",
        "x-upsert": "true"
    }
    
    print(f"Uploading {file_name} to Supabase storage...")
    try:
        with open(file_path, 'rb') as f:
            file_data = f.read()
        
        upload_req = urllib.request.Request(upload_url, data=file_data, headers=upload_headers, method='POST')
        with urllib.request.urlopen(upload_req) as upload_res:
            print(f"Upload success! Status: {upload_res.status}")
        return f"{url}/storage/v1/object/public/{bucket}/{remote_path}"
    except Exception as err:
        print(f"Failed to upload {file_name}: {err}")
        return None

# Target catalog IDs where we want to keep both images strictly same (identical)
target_catalog_ids = ["S-BAL-001", "S-LOU-001", "S-JOR-001"]

# 3. Update catalogs one-by-one to clear product_ids and update images
for item in catalogs:
    uuid_id = item.get("id")
    cid = item.get("catalog_id")
    images = item.get("product_images") or []
    
    update_data = {
        "product_ids": None
    }
    
    if cid in target_catalog_ids:
        print(f"\nProcessing updates for {cid}...")
        # Keep both images strictly identical as requested
        first_url = images[0] if len(images) > 0 else ""
        update_data["product_images"] = [first_url, first_url]
        print(f"Setting product_images to: {update_data['product_images']}")
            
    # Run DB update for this catalog item
    print(f"Updating DB row for {cid} ({uuid_id})...")
    update_url = f"{url}/rest/v1/catalogs?id=eq.{uuid_id}"
    update_req = urllib.request.Request(update_url, data=json.dumps(update_data).encode('utf-8'), headers=db_headers, method='PATCH')
    try:
        with urllib.request.urlopen(update_req) as update_res:
            print(f"Successfully updated DB row. Status: {update_res.status}")
    except Exception as db_err:
        print(f"Failed to update database row for {cid}: {db_err}")

# Cleanup local temp files downloaded/generated
print("\nCleaning up local temporary image files in artifacts directory...")
for pattern in ["first_balenciaga.png", "first_louboutin.png", "first_jordan.png"]:
    try:
        os.remove(os.path.join(artifact_dir, pattern))
    except FileNotFoundError:
        pass

print("All updates completed successfully!")

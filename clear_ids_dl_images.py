import urllib.request
import urllib.error
import json
import os

url = "https://fjbwuzqberpkzpaukauq.supabase.co"
anon_key = "sb_publishable_LP6HLynRHTDgEX_TxcvEEQ_Ywd85-GQ"
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

# 2. Set product_ids to null for all catalog products
print("Clearing product_ids for all products...")
update_data = {
    "product_ids": None
}
update_req = urllib.request.Request(f"{url}/rest/v1/catalogs", data=json.dumps(update_data).encode('utf-8'), headers=db_headers, method='PATCH')
try:
    with urllib.request.urlopen(update_req) as update_res:
        print(f"Cleared product_ids for all products. Status: {update_res.status}")
except Exception as e:
    print("Failed to clear product_ids:", e)

# 3. Fetch first image of Balenciaga, Louboutin, Jordan 1
fetch_req = urllib.request.Request(f"{url}/rest/v1/catalogs?select=catalog_id,product_images", headers=db_headers, method='GET')
try:
    with urllib.request.urlopen(fetch_req) as fetch_res:
        catalogs = json.loads(fetch_res.read().decode('utf-8'))
        
        target_ids = {
            "S-BAL-001": "first_balenciaga.png",
            "S-LOU-001": "first_louboutin.png",
            "S-JOR-001": "first_jordan.png"
        }
        
        for item in catalogs:
            cid = item.get("catalog_id")
            images = item.get("product_images")
            if cid in target_ids and images and len(images) > 0:
                first_img_url = images[0]
                target_filename = target_ids[cid]
                target_path = os.path.join(artifact_dir, target_filename)
                
                print(f"Downloading first image for {cid} from {first_img_url} to {target_path}...")
                headers_ua = {'User-Agent': 'Mozilla/5.0'}
                img_req = urllib.request.Request(first_img_url, headers=headers_ua)
                try:
                    with urllib.request.urlopen(img_req) as img_res:
                        with open(target_path, 'wb') as f:
                            f.write(img_res.read())
                    print("Download completed successfully.")
                except Exception as dl_err:
                    print(f"Failed to download image for {cid}: {dl_err}")
                    
except Exception as e:
    print("Failed to fetch catalogs:", e)

print("Setup script completed.")

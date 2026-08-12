import requests

print("Application started")
print(requests.get("https://example.com").status_code)

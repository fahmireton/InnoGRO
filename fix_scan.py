path = r'd:\demo_app\lib\services\scan_service.dart'
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()
# Keep only first 177 lines (new ScanService class)
with open(path, 'w', encoding='utf-8') as f:
    f.writelines(lines[:177])
print(f"Fixed. Lines: {len(lines[:177])}")
print("Last line:", lines[176].strip())

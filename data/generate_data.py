import csv
import random
from datetime import datetime, timedelta

start = datetime.now() - timedelta(hours=1)

with open("sensor_data.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["timestamp", "temperature", "humidity"])

    for i in range(360):
        ts = start + timedelta(seconds=i * 10)
        writer.writerow([
            ts.isoformat(),
            round(random.uniform(20, 30), 2),
            round(random.uniform(40, 70), 2)
        ])

import os
import csv
import random
import datetime

def generate_temperature_csv(filename, num_records = 1000):
    if num_records < 0:
        raise ValueError("Number of records must be a positive integer.")
    
    cities = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix"]
    header = ["City", "Temperature (C)", "Timestamp"]
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    
    try:
        with open(filename, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(header)
            
            for _ in range(num_records):
                city = random.choice(cities)
                temperature = round(random.uniform(-30.0, 50.0), 2)
                time = datetime.datetime.now().isoformat()
                
                writer.writerow([city, temperature, time])
    except (IOError, OSError) as e:
        raise IOError(f"Error writing to file {filename}: {e}")            
    

if __name__ == "__main__":
    generate_temperature_csv("data/temperature_data.csv")
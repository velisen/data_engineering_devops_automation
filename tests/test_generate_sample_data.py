import os
from scripts.generate_sample_data import generate_temperature_csv
import pytest
import csv
from datetime import datetime

@pytest.fixture
def temp_csv_file(tmp_path):
    return str(tmp_path / "test_temperature_data.csv")

def test_generate_temperature_csv_file(temp_csv_file):
    generate_temperature_csv(temp_csv_file, num_records=10)
    assert os.path.isfile(temp_csv_file)
    
def test_generate_temperature_csv_creates_file(temp_csv_file):
    generate_temperature_csv(temp_csv_file, num_records=10)
    assert os.path.exists(temp_csv_file)
    
def test_generate_temperature_csv_header(temp_csv_file):
    generate_temperature_csv(temp_csv_file, num_records=1)
    with open(temp_csv_file, 'r') as f:
        reader = csv.reader(f)
        header = next(reader)
        
        assert header == ["City", "Temperature (C)", "Timestamp"]
        
def test_generate_temperature_csv_content(temp_csv_file):
    num_records = 5
    generate_temperature_csv(temp_csv_file, num_records=num_records)
        
    with open(temp_csv_file, 'r') as f:
        reader = csv.reader(f)
        next(reader)
        rows = list(reader)
        
        valid_cities = {"New York", "Los Angeles", "Chicago", "Houston", "Phoenix"}
        for row in rows:
            #test city
            assert row[0] in valid_cities
            
            #test temperature
            temp = float(row[1])
            assert -30 <= temp <= 50
            
            #test timestamp
            
            timestamp = datetime.fromisoformat(row[2])
            assert isinstance(timestamp, datetime)
            
def test_generate_temperature_csv_different_sizes(temp_csv_file):
    test_sizes = [0, 1, 10, 100]
    
    for size in test_sizes:
        generate_temperature_csv(temp_csv_file, num_records=size)
        with open(temp_csv_file, 'r') as f:
            reader = csv.reader(f)
            next(reader)
            rows = list(reader)
            assert len(rows) == size
            
def test_generate_temperature_csv_invalid_input(temp_csv_file):
    with pytest.raises(ValueError):
        generate_temperature_csv(temp_csv_file, num_records=-1)
        
def test_generate_temperature_csv_file_permissions(tmp_path):
    dir_path = tmp_path / "test_dir.csv"
    dir_path.mkdir()
    
    with pytest.raises(IOError):
        generate_temperature_csv(str(dir_path), num_records=1)
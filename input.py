import numpy as np
import pandas as pd
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

def connect_to_database():

    database = os.environ.get("DATABASE")
    username = os.environ.get("USERNAME")
    password = os.environ.get("PASSWORD")
    ip_address = os.environ.get("IP_ADDRESS")
    port = os.environ.get("PORT")

    connection_string = f"dbname = {database} user= {username} password={password} host={ip_address} port={port}"

    conn = psycopg2.connect("dbname = dbname_here user= user password=password host=IP_address_here port=port_number_here")
    
    return conn



if __name__ == "__main__":
    conn = connect_to_database()
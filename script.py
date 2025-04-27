
from sqlalchemy import create_engine
import pandas as pd

df = pd.read_csv(r'C:\Users\shrey\Desktop\DataEngineeringMasterClass\SQL-Project\Netflix Project\netflix_titles.csv', encoding='utf-8')

# Define connection parameters
server = 'SHREY-GALAXYBOO'
database = 'projects_db'

# Create the connection URL
connection_url = (
    f"mssql+pyodbc://@{server}/{database}"
    "?driver=ODBC+Driver+17+for+SQL+Server"
    "&trusted_connection=yes"
)

# Create the engine
engine = create_engine(connection_url)

# Connect and test
conn = engine.connect()
print('Connection made successfully!')

df.to_sql('netflix_raw', index=False, con=conn, if_exists='replace')
print('Data Successfully Loaded into SQL Server!')

conn.close()
import pandas as pd

data = pd.read_csv("mandi_data_full.csv")
print(list(data.columns))
for col in data.columns:
    print(repr(col))
    data = pd.read_csv("mandi_data_full.csv", encoding='utf-8-sig')
data.columns = data.columns.str.strip().str.replace('\ufeff','')  # ⚡ Remove invisible BOM & spaces

print(list(data.columns))
# Should now print: ['Crop', 'Market', 'Variety', 'Modal Price']

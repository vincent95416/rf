import pandas as pd
import statsmodels.api as sm
import numpy as np
import time
from concurrent.futures import ThreadPoolExecutor

start_time = time.time()
dfs =[]

def dataframe_simplified(file_path, original_col, output_name):
    """
    xls資料格式標準化，預處理 DataFrame，從檔案讀取資料、設定欄位名稱、移除標題列，並選取指定欄位，更名並轉換為 float 類型
    Args:
        file_path (str): HTML 檔案(.xls)路徑
        original_col (str): 要選取的原始欄位名稱
        output_name (str): 輸出 DataFrame 的欄位名稱
    Returns:
        pd.DataFrame: 預處理後的 DataFrame，僅包含一個欄位，欄位名稱為 output_name，數據類型為 float
    """
    df = pd.read_html(file_path)[0] #讀取檔案.xls，預設都是html，因此取第一個表格，即[0]
    original_columns = df.iloc[0] #設定欄位名稱並移除第一行
    df.columns = original_columns
    df = df.iloc[1:].reset_index(drop=True)
    df_processed = df[[original_col]].copy() #選取指定欄位並複製
    df_processed = df_processed.rename(columns={original_col: output_name}) #欄位更改名稱
    df_processed[output_name] = df_processed[output_name].astype(float) #確保數據是 float
    return df_processed

def load_dataframe(file_info):
    """
    並行加載數據框架的輔助函式，用於搭配 ThreadPoolExecutor 進行並行資料載入，
    使用 dataframe_simplified 函式處理單個檔案，並移除所有值皆為 NaN 的列。
    Args:
        file_info(tuple) :包含檔案資訊的 tuple，格式為 (file_path, original_cole, output_name)。
                             - file_path (str): HTML 檔案 (.xls) 路徑。
                             - original_col (str): 要選取的原始欄位名稱。
                             - output_name (str): 輸出 DataFrame 的欄位名稱。
    """

    file_path, col_name, output_name = file_info
    df = dataframe_simplified(file_path, col_name, output_name)
    return df.dropna(how='all')

#可將檔案資訊移至外部環境文件
file_infos = [
        ('C520_Electricity_meter_1_2025-01-01To2025-02-19.xls', '總累積用電(KWH)', '冷卻水塔'),
        ('C520_Electricity_meter_3_2025-01-01To2025-02-19.xls', '總累積用電(KWH)', '冰水主機'),
        ('C520_Electricity_meter_5_2025-01-01To2025-02-19.xls', '總累積用電(KWH)', '空壓機01'),
        ('C520_Electricity_meter_6_2025-01-01To2025-02-19.xls', '總累積用電(KWH)', '空壓機02'),
        ('C520_Electricity_meter_8_2025-01-01To2025-02-19.xls', '總累積用電(KWH)', '台炭')
    ]

with ThreadPoolExecutor() as executor:
    dfs = list(executor.map(load_dataframe, file_infos))
df = pd.concat(dfs, axis=1)
df_filled = df.fillna(0)

load_time = time.time()
exe1_time = load_time - start_time
print(f"\n資料讀取時間: {exe1_time:.4f} 秒")


features = df_filled.drop(columns=['台炭'])
x = sm.add_constant(features)
y = df_filled['台炭']
variables = features.columns
print("各特徵的資料數:", features.count())
print("目標變數的資料數:", y.count())
#print("各個特徵的缺失值:", features.isnull().sum())

def regression_analysis(features, target, variable_names):
    """
        執行迴歸分析並返回結果
        Args:
            features (pd.DataFrame): 特徵 DataFrame。
            target (pd.Series): 目標變數 Series。
            variable_names (list, optional): 要進行迴歸分析的特徵變數名稱列表。
                                        如果為 None，則使用 features DataFrame 的所有欄位。
                                        預設為 None。
        Returns:
            dict: 迴歸分析結果
        """
    results = {}
    if variable_names is None:
        variable_names = features.columns

    for variable_name in variable_names:
        x_single = sm.add_constant(features[[variable]])
        model_single = sm.OLS(y, x_single)
        fit_results = model_single.fit()

        results[variable_name] = {
            'R-squared': fit_results.rsquared,
            'Adj. R-squared': fit_results.rsquared_adj,
            'P-value': fit_results.pvalues[variable_name],
            'Coefficient':fit_results.params[variable_name]
        }

    return results

regression_results = regression_analysis(x, y, features.columns)

for variable, result_dict in regression_results.items(): # 迴圈處理 results 字典
    print(f"\n自變數: {variable}")
    print(f"R-squared: {result_dict['R-squared']:.4f}") # 從 result_dict 字典取值
    print(f"Adj. R-squared: {result_dict['Adj. R-squared']:.4f}") # 從 result_dict 字典取值
    print(f"P-value: {result_dict['P-value']:.4f}") # 從 result_dict 字典取值
    print(f"Coefficient: {result_dict['Coefficient']:.4f}") # 從 result_dict 字典取值

end_time = time.time()
exe2_time = end_time - start_time
print(f"\n程式碼執行時間: {exe2_time:.4f} 秒")
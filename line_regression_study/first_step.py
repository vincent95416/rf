import pandas as pd
import statsmodels.api as sm
import time
from concurrent.futures import ThreadPoolExecutor
start_time = time.time()
class Regression:
    def __init__(self, file_infos):
        """
        初始化 Regression 類別。
        Args:
            file_infos (list): 檔案資訊列表，格式為 (file_path, original_col, output_name)。
        """
        self.file_infos = file_infos
        self.dataframes = []
        self.df = None

    def dataframe_simplified(self, file_path, original_col, output_name):
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

    def load_dataframe(self, file_info):
        """
        並行加載數據框架的輔助函式，用於搭配 ThreadPoolExecutor 進行並行資料載入，
        使用 dataframe_simplified 函式處理單個檔案，並移除所有值皆為 NaN 的列。
        Args:
            file_info(tuple) :包含檔案資訊的 tuple，格式為 (file_path, original_col, output_name)。
                                 - file_path (str): HTML 檔案 (.xls) 路徑。
                                 - original_col (str): 要選取的原始欄位名稱。
                                 - output_name (str): 輸出 DataFrame 的欄位名稱。
        """
        file_path, col_name, output_name = file_info
        df = self.dataframe_simplified(file_path, col_name, output_name)
        return df.dropna(how='all')

    def load_all_data(self):
        """
        使用 ThreadPoolExecutor 並行載入所有資料檔案，並合併為單一 DataFrame。
        Returns:
            pd.DataFrame: 合併後的 DataFrame，欄位為各檔案的 output_name，NaN 值填補為 0。
        """
        with ThreadPoolExecutor() as executor:
            self.dataframes = list(executor.map(self.load_dataframe, self.file_infos))
            self.df = pd.concat(self.dataframes, axis=1).fillna(0)
            return self.df

    def regression_analysis(self):
        """
        使用 '台炭' 作為目標變數，對其他特徵分別進行單變數迴歸分析，
        並返回每個特徵的 R-squared、Adj. R-squared、P-value 與 Coefficient
        Returns:
            dict: 迴歸分析結果字典，key 為變數名稱，value 為包含迴歸指標的字典。
        """
        if self.df is None:
            raise ValueError("DataFrame 尚未載入，請先呼叫 load_all_data()")

        features = self.df.drop(columns=['台炭'])
        target = self.df['台炭']
        results = {}
        for variable in features.columns:
            x_single = sm.add_constant(features[[variable]])
            model_single = sm.OLS(target, x_single)
            fit_results = model_single.fit()
            results[variable] = {
                'R-squared': fit_results.rsquared,
                'Adj. R-squared': fit_results.rsquared_adj,
                'P-value': fit_results.pvalues[variable],
                'Coefficient': fit_results.params[variable]
            }
        return results

    def run_analysis(self):
        """
        整體流程：讀取所有資料後進行迴歸分析，並輸出結果
        """
        total_start = time.time()
        self.load_all_data()
        regression_results = self.regression_analysis()

        # 輸出基本資訊
        features = self.df.drop(columns=['台炭'])
        target = self.df['台炭']
        print("各特徵的資料數:", features.count().to_dict())
        print("目標變數的資料數:", target.count())

        # 輸出每個變數的迴歸結果
        for variable, result_dict in regression_results.items():
            print(f"\n自變數: {variable}")
            print(f"R-squared: {result_dict['R-squared']:.4f}")
            print(f"Adj. R-squared: {result_dict['Adj. R-squared']:.4f}")
            print(f"P-value: {result_dict['P-value']:.4f}")
            print(f"Coefficient: {result_dict['Coefficient']:.4f}")

        print(f"\n程式碼執行時間: {time.time() - total_start:.4f} 秒")
        return regression_results

if __name__ == '__main__':
    file_infos = [
        ('C520_Electricity_meter_1_2025-01-01To2025-02-19.xls', '總累積用電(KWH)', '冷卻水塔'),
        ('C520_Electricity_meter_3_2025-01-01To2025-02-19.xls', '總累積用電(KWH)', '冰水主機'),
        ('C520_Electricity_meter_5_2025-01-01To2025-02-19.xls', '總累積用電(KWH)', '空壓機01'),
        ('C520_Electricity_meter_6_2025-01-01To2025-02-19.xls', '總累積用電(KWH)', '空壓機02'),
        ('C520_Electricity_meter_8_2025-01-01To2025-02-19.xls', '總累積用電(KWH)', '台炭')
    ]

    analyzer = Regression(file_infos)
    analyzer.run_analysis()
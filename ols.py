from statistics import correlation
from sklearn import datasets
import pandas as pd
import statsmodels.api as sm

data = pd.read_csv('C520_Electricity_meter_1.csv')
data_cleaned = data.drop(columns=['#time'])
california = datasets.fetch_california_housing()
df = pd.DataFrame(california.data, columns=california.feature_names)

df = pd.DataFrame(data)
x = data[['freq', 'wSum']]  #自變數
y = data['KWH']  #目標變數
# 加入常數項（截距）
X = sm.add_constant(x)
# 建立線性回歸模型
model = sm.OLS(y, X)
# 訓練模型
results = model.fit()
顯示回歸結果
correlation_matrix = df.corr()
correlation_with_med = correlation_matrix['MedInc'].drop('MedInc')
var_max = correlation_with_med.idxmax()
var_max_value = correlation_with_med.max()
print(f"與 MedInc 相關性最大的變數是 {var_max}，相關係數為 {var_max_value}")

# iris = datasets.load_iris()
# df = pd.DataFrame(iris.data, columns=iris.feature_names)
# df["target"] = iris.target
# print(df)
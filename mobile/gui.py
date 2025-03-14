import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import subprocess
import webbrowser
import os
import app_var
import threading

class RobotGUI(tk.Tk):
    """RobotFramework 測試工具類別，繼承tkinter.Tk，作為介面程式的主視窗"""
    def __init__(self):
        """初始化 GUI 視窗，設定標題、大小，並建立 UI 元件"""
        super().__init__()
        self.title("Robotframework 測試工具")
        self.geometry("500x550")    #寬*高
        self.variables = {}  # 存放變數名稱與對應輸入框的字典
        self.current_test_process = None  # 用於存儲測試程序的執行狀態
        # 設定當使用者關閉視窗時，執行 self.on_closing 方法
        self.protocol("WM_DELETE_WINDOW", self.on_closing)
        self.create_widgets()

    def create_widgets(self):
        """建立視窗內的UI元件，輸入框、按鈕與變數設定"""
        # 先建立環境選擇區域
        env_frame = tk.Frame(self)
        env_frame.pack(pady=10, fill="x")
        tk.Label(env_frame, text="選擇環境:").pack(side=tk.LEFT, padx=5)

        self.environment_var = tk.StringVar(self)
        env_combobox = ttk.Combobox(env_frame, textvariable=self.environment_var, values=list(app_var.ENVIRONMENTS.keys()), state="readonly", width=15)
        env_combobox.pack(side=tk.LEFT, padx=(5, 10))
        env_combobox.bind("<<ComboboxSelected>>", lambda e: self.on_environment_change())
        # 建立測試案例選擇區域
        tk.Label(self, text="測試案例:").pack(pady=(10, 0))
        self.test_entry = tk.Entry(self, width=60)  # 輸入框
        self.test_entry.pack()
        tk.Button(self, text="選擇檔案", command=self.browse_file).pack(pady=(2, 5))
        # 建立變數設定的區域
        self.variables_container = tk.Frame(self)
        self.variables_container.pack(fill="both", expand=True, pady=10)
        # 執行按鈕
        self.run_button = tk.Button(self, text="執行測試", command=self.run_robot_test)
        self.run_button.pack(pady=(10, 50))
        # 預設先選擇stage環境
        self.environment_var.set('stage')
        self.on_environment_change()

    def on_environment_change(self):
        """當環境選擇改變時，更新變數設定區域"""
        # 清空變數容器
        for widget in self.variables_container.winfo_children():
            widget.destroy()

        self.variables = {}  # 重設變數字典

        # 獲取當前選擇的環境
        current_env = self.environment_var.get()
        # 定義當前環境配置的變數
        env_config = app_var.ENVIRONMENTS[current_env]

        # 建立變數標題
        tk.Label(self.variables_container,
                 text=f"{current_env.capitalize()} 環境變數設定:",
                 font=("Helvetica", 10, "bold")
                 ).pack(anchor="w", padx=10, pady=(0, 5))

        # 根據選擇的環境(env_config)建立變數設定UI
        for key, def_value in env_config["variables"].items():
            frame = tk.Frame(self.variables_container)
            frame.pack(pady=2, fill="x")

            label = tk.Label(frame, text=f"{key}:")
            label.pack(side=tk.LEFT, padx=5)

            if key in env_config["combobox_variables"]:
                self.variables[key] = tk.StringVar(self)
                self.variables[key].set(def_value)
                option_values = env_config["combobox_options"].get(key, [])
                entry = ttk.Combobox(frame, textvariable=self.variables[key], values=option_values)
                entry.pack(side=tk.LEFT, expand=True, fill="x", padx=10)
            else:
                entry = tk.Entry(frame, width=40)
                entry.pack(side=tk.LEFT, expand=True, fill="x", padx=10)
                entry.insert(0, def_value)  # 預先填入預設值
                self.variables[key] = entry

    def browse_file(self):
        """使用檔案對話框選擇 .robot 測試檔"""
        filename = filedialog.askopenfilename(filetypes=[("Robot Framework Test", "*.robot")])
        if filename:
            self.test_entry.delete(0, tk.END)
            self.test_entry.insert(0, filename)

    def run_robot_test(self):
        """執行 Robot Framework 測試"""
        self.run_button.config(state=tk.DISABLED)  # 禁用「執行」按鈕，避免重複點擊
        test_case = self.test_entry.get().strip()  # 從輸入框取得測試案例名稱，並去除前後空白

        if not test_case:
            messagebox.showerror("錯誤", "請選擇要執行的 Test Case")
            self.run_button.config(state=tk.NORMAL)
            return

        # 設定固定變數 (系統參數) - 從環境變數(app_var.py)中取得
        os.environ["APPIUM_URL"] = app_var.APPIUM_URL
        os.environ["PLATFORM_NAME"] = app_var.PLATFORM_NAME
        os.environ["AUTOMATION_NAME"] = app_var.AUTOMATION_NAME
        os.environ["APP_PACKAGE"] = app_var.APP_PACKAGE
        os.environ["APP_ACTIVITY"] = app_var.APP_ACTIVITY
        os.environ["INSTALL_TIME"] = str(app_var.INSTALL_TIME)

        # 獲取當前環境
        current_env = self.environment_var.get()
        os.environ["ENVIRONMENT"] = current_env

        # 設定使用者變數
        robot_variables = ["--variable", f"environment:{current_env}"]

        for key, entry in self.variables.items():
            if hasattr(entry, 'get'):
                value = entry.get().strip()
            else:
                value = entry.strip()

            if key == "version":  # 如果是 "version" 變數，則加上 "版本號\nv" 字首
                value = f"版本號\n{value}"

            os.environ[key] = value

            # 添加到 Robot Framework 命令行參數
            robot_variables.append("--variable")
            robot_variables.append(f"{key}:{value}")

        test_thread = threading.Thread(target=self.run_test_thread, args=(test_case, robot_variables))
        test_thread.daemon = True
        test_thread.start()

    def on_closing(self):
        """檢查是否有正在執行的測試程序，兩秒後會強制終止"""
        if self.current_test_process:
            try:
                self.current_test_process.terminate()
                self.current_test_process.wait(timeout=2)
            except subprocess.TimeoutExpired:
                self.current_test_process.kill()
        self.quit()

    def run_test_thread(self, test_case, robot_variables):
        """在單獨的線程中執行測試，避免凍結 GUI"""
        command = ["robot"] + robot_variables + [test_case]
        print("執行指令:", " ".join(command))

        try:
            self.current_test_process = subprocess.Popen(command)
            # 等待測試程序結束，並將此程序判斷設置為None，確保變數清除
            return_code = self.current_test_process.wait()
            self.current_test_process = None

            if return_code == 0:
                self.after(0, lambda: [
                    messagebox.showinfo("成功", "測試執行完成"),
                    webbrowser.open("report.html")
                ])
            else:
                self.after(0, lambda: messagebox.showerror("錯誤", "測試執行失敗"))
                self.after(0, lambda: webbrowser.open("log.html"))

        except Exception as e:
            self.after(0, lambda: messagebox.showerror("錯誤", f"測試執行異常: {str(e)}"))
            self.current_test_process = None

        self.after(0, lambda: self.run_button.config(state=tk.NORMAL))


if __name__ == '__main__':
    root = RobotGUI()
    root.mainloop()
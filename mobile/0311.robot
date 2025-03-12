*** Settings ***
Library           AppiumLibrary
Library    Process
Library    String
Library    DateTime
Variables    app_var.py
Suite Setup    Initialize Test Suite
Suite Teardown    Close Application

*** Keywords ***
Initialize Test Suite
    Open Test Application
    Initialize Window Size

Open Test Application
    Open Application    ${APPIUM_URL}
    ...                 platformName=${PLATFORM_NAME}
    ...                 appium:automationName=${AUTOMATION_NAME}
    ...                 appium:deviceName=${DEVICE_NAME}
    ...                 appium:appPackage=${APP_PACKAGE}
    ...                 appium:appActivity=${APP_ACTIVITY}
    ...                 appium:uiautomator2ServerInstallTimeout=${INSTALL_TIME}
    ...                 appium:autoGrantPermissions=true    #自動授予所需的其他權限(相機、位置)
    ...                 appium:newCommandTimeout=0    #沒有新命令的狀況下，等待的timeout時間，設置0表示可以無限等待，避免在長時間測試中
    ...                 appium:ensureWebviewsHavePages=true    #確保在webview中載入頁面後才允許測試操作
    ...                 appium:nativeWebScreenshot=true    #使用原生app截圖
    ...                 appium:autoAcceptAlerts=true    #自動接受所有來自權限請求和系統彈窗
    ...                 appium:noReset=true   #指定是否在測試啟動和結束時避免appium進行重置操作，設置T則不清除快取及設定、不解安裝
    ...                 appium:fullReset=false    #最全面的環境重置邏輯，設置T會在session啟動前解除並重新安裝，且另需要app指定路徑，安裝包的檔案
    #...                 appium:app="C:\Users\User\Downloads\app.apk"    #安裝包的路徑，可配合fullreset:True
    ${Width}    Get Window Width
    ${Height}    Get Window Height
    
Initialize Window Size
    ${Width}=    Get Window Width
    ${Height}=   Get Window Height
    Set Global Variable    ${Width}
    Set Global Variable    ${Height}
    
Click And Input
    [Arguments]    ${locator}    ${expected_text}
    Click Element    ${locator}
    Input Text    ${locator}    ${expected_text}
    

Check All Elements Have Attribute
    [Arguments]    ${locator}    ${verify_attr}
    ${elements}    Get Webelements    ${locator}
    ${list_count}    Get Length    ${elements}
    Run Keyword If    ${list_count} == 0    Fail
    FOR    ${element}    IN    @{elements}
        Element Attribute Should Match    ${locator}    ${verify_attr}    true
    END
    
Verify Element Enabled And Click
    [Arguments]    ${locator}
    Element Should Be Enabled    ${locator}
    Click Element    ${locator}

Get Time Range From Element
    ${time_range_element}=    Get Webelement    xpath=//*[contains(@content-desc, "下載")]
    ${time_range_text}=    Get Element Attribute    ${time_range_element}    content-desc
    # 使用正則表達式提取【】之間的文字
    ${time_range}=    Get Regexp Matches    ${time_range_text}    【(.+?)】    1
    ${time_range}=    Set Variable    ${time_range}[0]
    Set Test Variable    ${time_range}

Check Video File Exists
    [Arguments]    ${filename}
    Run Process    adb    shell    ls    /storage/emulated/0/Download/${filename}
    #Should Be Equal As Integers    ${ls_result.rc}    1    找不到下載的影片檔案: ${filename}
    Run Process    adb    shell    stat    -f    %s    /storage/emulated/0/Download/${filename}
    
Verify Download File
    ${name_formatted}=    Replace String    ${time_range}    :    _
    Log    原始時間範圍: ${time_range}    level=INFO
    Log    格式化後名稱: ${name_formatted}    level=INFO
    Set Test Variable    ${EXPECTED_FILENAME}    ${name_formatted}.mp4
    Wait Until Keyword Succeeds    15s    5s    Check Video File Exists    ${EXPECTED_FILENAME}

Swipe Down To Find Element
    [Arguments]    ${locator}    ${start_y}    ${end_y}
    ${visible}    Set Variable    ${FALSE}
    FOR    ${i}    IN RANGE    3
        ${visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}
        Run Keyword If    ${visible}    Exit For Loop
        Swipe By Percent    50    ${start_y}    50    ${end_y}    1000
    END    
    Run Keyword If    not ${visible}    Fail    Element not found after scrolling

From Element Get Version
    [Arguments]    ${locator}    ${attribute}
    ${version_element}    Get Webelement    ${locator}
    ${element_text}    Get Element Attribute    ${locator}    ${attribute}
    ${version_text}    Split String    ${element_text}    \n
    ${version_with_v}    Set Variable    ${version_text}[1]
    
*** Test Cases ***
登入
    Wait Until Page Contains Element    android:id/content
    Wait Until Element Is Visible    android=new UiSelector().description("登入")
    Click Element    android=new UiSelector().className("android.widget.EditText").instance(0)
    Sleep    1s
    Click Element    android=new UiSelector().className("android.widget.EditText").instance(0)
    Input Text    android=new UiSelector().className("android.widget.EditText").instance(0)    ${username}
    Click Element    android=new UiSelector().className("android.widget.EditText").instance(1)
    Sleep    1s
    Click Element    android=new UiSelector().className("android.widget.EditText").instance(1)
    Input Text    android=new UiSelector().className("android.widget.EditText").instance(1)    ${password}
    Sleep    1s
    Click Element    accessibility_id=登入
    Click Element    xpath=//android.widget.Button[@content-desc="登入"]
	Sleep    2s
    ${popup_visible}    Run Keyword And Return Status    Element Should Be Visible    accessibility_id=歡迎您使用本服務，本服務採用雲端機制提供 2 天全時回放，若您有需要，請至檔案或帳號設定介面將本功能調整為開啟，感謝您的使用~
    IF    ${popup_visible}
        Click Element    accessibility_id=我知道了
    END
    Wait Until Element Is Visible    accessibility_id=${title}

即時影像
    Wait Until Element Is Visible    android = new UiSelector().className("android.widget.HorizontalScrollView")
    Click Element    android = new UiSelector().className("android.view.View").instance(11)

    ${x1}=    Evaluate    ${Width} * 0.75
    ${x2}=    Evaluate    ${Width} * 0.25
    ${y1}=    Evaluate    ${Height} * 0.25

    FOR    ${index}    IN RANGE    10
        ${result}=    Run Keyword And Ignore Error    Page Should Contain Element    accessibility_id=${cam_skywatch}
        Run Keyword If    '${result[0]}' == 'PASS'    Exit For Loop
        Run Keyword If    '${result[0]}' == 'FAIL'    Swipe    ${x1}    ${y1}    ${x2}    ${y1}    500
        Run Keyword If    '${result[0]}' == 'FAIL'    Sleep    1s
    END
    Click Element    android = new UiSelector().className("android.widget.Button").instance(1)

AI監控告警
    Wait Until Element Is Visible    accessibility_id=排程設定
    Verify Element Enabled And Click    accessibility_id=全部關閉
    Wait Until Element Is Visible    accessibility_id=AI監控告警\n全部停用中
    Click Element    accessibility_id=自動化\n第 3 個分頁 (共 5 個)
    Wait Until Element Is Visible    accessibility_id=自動化與通知
    Click Element    accessibility_id=AI監控告警\n第 2 個分頁 (共 3 個)
    Check All Elements Have Attribute    android=new UiSelector().description("停用中")    selected
    Click Element    accessibility_id=首頁\n第 1 個分頁 (共 5 個)
    Wait Until Element Is Visible    accessibility_id=${title}
    Verify Element Enabled And Click    accessibility_id=全部開啟
    Wait Until Element Is Visible    accessibility_id=AI監控告警\n全部啟用中
    Click Element    accessibility_id=自動化\n第 3 個分頁 (共 5 個)
    Wait Until Element Is Visible    accessibility_id=自動化與通知
    Click Element    accessibility_id=AI監控告警\n第 2 個分頁 (共 3 個)
    Check All Elements Have Attribute    android=new UiSelector().description("啟用中")    selected
    Click Element    accessibility_id=首頁\n第 1 個分頁 (共 5 個)

門禁開關
    Wait Until Element Is Visible    accessibility_id=門禁開關
    Click Element    accessibility_id=${c1_name}
    ${popup_visible}    Run Keyword And Return Status    Element Should Be Visible     accessibility_id=提示\n親愛的用戶您好，為您的使用安全，門禁服務需申辦攝影機動使用
    Run Keyword If    ${popup_visible}    Log    鐵捲門尚未綁定攝影機    WARN
    Wait Until Element Is Visible    accessibility_id=紗罩
    Click Element    android=new UiSelector().className("android.widget.ImageView").instance(0)
    Click Element    android=new UiSelector().className("android.widget.ImageView").instance(2)
    Click Element    android=new UiSelector().className("android.widget.ImageView").instance(1)
    Wait Until Element Is Visible    accessibility_id=已執行    10s
    Click Element    class=android.widget.Button
    Wait Until Page Does Not Contain Element    accessibility_id=紗罩

自動化
    Click Element    accessibility_id=自動化\n第 3 個分頁 (共 5 個)
    Wait Until Element Is Visible    accessibility_id=自動化與通知
    Click Element    accessibility_id=自動化排程設定\n第 3 個分頁 (共 3 個)
    Verify Element Enabled And Click    accessibility_id=新增排程
    Wait Until Element Is Visible    accessibility_id=新增排程及告警\n排程名稱
    Click And Input    class=android.widget.EditText    robot
    Sleep    1s
    Verify Element Enabled And Click    accessibility_id=下一步-設定條件
    Wait Until Element Is Visible    accessibility_id=條件規則\n請選擇類型\n單一符合 ： 僅單一條件符合即執行\n同時符合 ： 所有條件符合後執行
    Click Element    accessibility_id=條件規則\n請選擇類型\n單一符合 ： 僅單一條件符合即執行\n同時符合 ： 所有條件符合後執行
    Wait Until Element Is Visible    android=new UiSelector().className("android.view.View").instance(5)
    Click Element    accessibility_id=單一符合
    Wait Until Element Is Visible    accessibility_id=新增條件
    Click Element    accessibility_id=新增條件
    Wait Until Element Is Visible    accessibility_id=條件1\n設備類型\n攝影機\n設備
    Click Element    accessibility_id=選擇設備
    Wait Until Element Is Visible    accessibility_id=選擇設備
    Swipe Down To Find Element    xpath=//android.view.View[contains(@content-desc, "${cam_nvr}")]/android.widget.RadioButton    75    50
    Click Element    xpath=//android.view.View[contains(@content-desc, "${cam_nvr}")]/android.widget.RadioButton
    Verify Element Enabled And Click    accessibility_id=加入
    Sleep    1s
    Verify Element Enabled And Click    accessibility_id=下一步-設定執行
    Wait Until Element Is Visible    accessibility_id=告警通知
    Wait Until Element Is Visible    accessibility_id=${cam_nvr}
    #Swipe Down To Find Element    accessibility_id=新增告警通知    75    50
    Click Element    accessibility_id=新增告警通知
    Wait Until Element Is Visible    accessibility_id=通知項目1\n通知類型\n緊急聯絡人
    Sleep    1s
    #第二個通知項目
    Swipe Down To Find Element    accessibility_id=新增告警通知    75    50
    Verify Element Enabled And Click    accessibility_id=新增告警通知
    Swipe Down To Find Element    accessibility_id=新增告警通知    75    50
    Wait Until Element Is Visible    accessibility_id=通知項目2\n通知類型\n緊急聯絡人
    Click Element    xpath=(//android.widget.Button[@content-desc="發送SMS"])[2]
    Wait Until Element Is Visible    xpath=//android.widget.FrameLayout[@resource-id="android:id/content"]/android.widget.FrameLayout/android.view.View/android.view.View/android.view.View/android.view.View[1]/android.view.View/android.view.View/android.view.View
    Click Element    accessibility_id=發送Email
    Sleep    1s
    #第三個通知項目
    Swipe Down To Find Element    accessibility_id=新增告警通知    75    50
    Verify Element Enabled And Click    accessibility_id=新增告警通知
    Swipe Down To Find Element    accessibility_id=新增告警通知    75    50
    Wait Until Element Is Visible    accessibility_id=通知項目3\n通知類型\n緊急聯絡人
    Click Element    xpath=(//android.widget.Button[@content-desc="發送SMS"])
    Sleep    1s
    Click Element    accessibility_id=外撥電話語音
    Wait Until Element Is Visible    accessibility_id=通知項目3\n通知類型\n外撥電話語音
    Click Element    accessibility_id=下一步
    Wait Until Element Is Visible    accessibility_id=週期
    Click Element    accessibility_id=選擇週期
    Wait Until Element Is Visible    accessibility_id=選擇時間
    Click Element    accessibility_id=星期一
    Wait Until Element Is Visible    android=new UiSelector().className("android.view.View").instance(6)
    Click Element    accessibility_id=00:00
    Click Element    accessibility_id=00:30
    Wait Until Element Is Visible    accessibility_id=時間\n00:00\n00:30
    Verify Element Enabled And Click    accessibility_id=確認
    Verify Element Enabled And Click    accessibility_id=完成
    Wait Until Element Is Visible    accessibility_id=自動化與通知
    Wait Until Element Is Visible    accessibility_id=#1\nrobot\n條件：\n${cam_nvr} 單一符合\n執行：\n彈窗告警視窗, 發送SMS, 發送Email, 外撥電話語音\n排程：\n星期一 00:00~00:30
    Click Element    xpath=//android.widget.FrameLayout[@resource-id="android:id/content"]/android.widget.FrameLayout/android.view.View/android.view.View/android.view.View/android.view.View[1]/android.view.View/android.view.View[2]/android.view.View/android.view.View/android.view.View/android.view.View/android.view.View[1]/android.widget.Button
    Wait Until Element Is Visible    accessibility_id=更多
    Click Element    accessibility_id=刪除
    Wait Until Element Is Visible    accessibility_id=刪除排程\n確定要刪除【robot】這項排程嗎？
    Click Element    accessibility_id=刪除
    Wait Until Page Does Not Contain Element    accessibility_id=#1\nrobot\n條件：\n${cam_nvr} 單一符合\n執行：\n彈窗告警視窗, 發送SMS, 發送Email, 外撥電話語音\n排程：\n星期一 00:00~00:30

檔案
    [Documentation]    進入檔案，開啟原先預設關閉的雲端錄影，並針對攝影機片段下載
    Click Element    accessibility_id=檔案\n第 4 個分頁 (共 5 個)
    Wait Until Element Is Visible    accessibility_id=全時錄影
    Click Element    accessibility_id=設定
    Sleep    1s
    ${button_x}    Evaluate    ${Width} * 0.9
    ${button_y}    Evaluate    ${Height} * 0.15
    Log    ${button_x}
    Log    ${button_y}
    @{positions}    Create List    ${button_x}    ${button_y}
    Tap With Positions    ${100}    ${positions}
    Sleep    4s
    Click Element    android=new UiSelector().className("android.widget.Button").instance(1)
    Wait Until Element Is Visible    accessibility_id=雲端錄影\n開啟中
    #這邊有bug，需要再點擊一次back
    Click Element    android=new UiSelector().className("android.widget.Button").instance(0)
    #從設備列表中滑動並找尋攝影機
    Swipe Down To Find Element    xpath=//android.view.View[contains(@content-desc, "${cam_nvr}")]    75    25
    Click Element    xpath=//android.view.View[contains(@content-desc, "${cam_nvr}")]
    Wait Until Element Is Visible    accessibility_id=${cam_nvr}
    #下載驗證，包含資料夾內的檔案檢查
    Click Element    accessibility_id=下載
    Sleep    3s
    Get Time Range From Element
    Click Element    accessibility_id=下載
    Wait Until Element Is Visible    accessibility_id=已下載    30s
    Verify Download File
    Click Element    accessibility_id=首頁\n第 1 個分頁 (共 5 個)
    ${half_y}    Evaluate    ${height}*0.5
    ${bugicon_visible}    Run Keyword And Return Status    Element Should Be Visible     android=new UiSelector().className("android.widget.Button").instance(4)
    Run Keyword If    ${bugicon_visible}    Drag And Drop    android=new UiSelector().className("android.widget.Button").instance(4)    accessibility_id=${title}
    Click Element    accessibility_id=系統\n第 5 個分頁 (共 5 個)
    Wait Until Element Is Visible    accessibility_id=系統管理
    Click Element    accessibility_id=操作記錄\n第 2 個分頁 (共 2 個)
    Swipe By Percent    50    75    50    50    1000
    Sleep    3s
    Wait Until Element Is Visible    android=new UiSelector().className("android.view.View").instance(12)    15s
    ${first_message}    Get Element Attribute    xpath=//android.widget.FrameLayout[@resource-id="android:id/content"]/android.widget.FrameLayout/android.view.View/android.view.View/android.view.View/android.view.View[1]/android.view.View/android.view.View[2]/android.view.View/android.view.View/android.view.View/android.view.View/android.view.View    content-desc
    Should Contain    ${first_message}    下載全時錄影檔案

新增子帳號，登入後刪除
    Click Element    accessibility_id=首頁\n第 1 個分頁 (共 5 個)
    ${half_y}    Evaluate    ${height}*0.5
    ${bugicon_visible}    Run Keyword And Return Status    Element Should Be Visible     android=new UiSelector().className("android.widget.Button").instance(4)
    Run Keyword If    ${bugicon_visible}    Drag And Drop    android=new UiSelector().className("android.widget.Button").instance(4)    accessibility_id=${title}
    Click Element    accessibility_id=系統\n第 5 個分頁 (共 5 個)
    Wait Until Element Is Visible    accessibility_id=系統管理
    Verify Element Enabled And Click    accessibility_id=新增帳號
    Click And Input    xpath=//android.widget.EditText[@hint='請輸入名稱']    cworobot
    Click Element    android=new UiSelector().className("android.widget.ScrollView")
    Click And Input    xpath=//android.widget.EditText[@hint='請輸入電話號碼']    0987654321
    Click Element    android=new UiSelector().className("android.widget.ScrollView")
    Click And Input    xpath=//android.widget.EditText[@hint='請輸入帳號']    cworobot
    Click Element    android=new UiSelector().className("android.widget.ScrollView")
    Swipe Down To Find Element    xpath=//android.widget.EditText[@hint='請輸入Email']    50    25
    Click And Input    xpath=//android.widget.EditText[@hint='請輸入密碼']    123456
    Click Element    android=new UiSelector().className("android.widget.ScrollView")
    Click And Input    xpath=//android.widget.EditText[@hint='請再次輸入密碼']    123456
    Click Element    android=new UiSelector().className("android.widget.ScrollView")
    Click And Input    xpath=//android.widget.EditText[@hint='請輸入Email']    q@q.q
    Verify Element Enabled And Click    accessibility_id=建立
    Wait Until Element Is Visible    accessibility_id=已建立
    Wait Until Element Is Visible    accessibility_id=cworobot\ncworobot\n***@q.q\n0987-654321
    Click Element    accessibility_id=首頁\n第 1 個分頁 (共 5 個)
    Verify Element Enabled And Click    android=new UiSelector().className("android.widget.ImageView").instance(1)
    Wait Until Element Is Visible    accessibility_id=住家資訊
    Swipe Down To Find Element    accessibility_id=${version}    75    50
    Swipe Down To Find Element    accessibility_id=登出    75    25
    Verify Element Enabled And Click    accessibility_id=登出
    Wait Until Page Contains Element    android:id/content
    Wait Until Element Is Visible    android=new UiSelector().description("登入")
    Click Element    xpath=//android.widget.EditText[@hint='請輸入帳號']
    Sleep    1s
    Click And Input    xpath=//android.widget.EditText[@hint='請輸入帳號']    cworobot
    Click Element    xpath=//android.widget.EditText[@hint='請輸入密碼']
    Sleep    1s
    Click And Input    xpath=//android.widget.EditText[@hint='請輸入密碼']    123456
    Click Element    android:id/content
    Verify Element Enabled And Click    //android.widget.Button[@content-desc="登入"]
    Wait Until Element Is Visible    accessibility_id=設定新密碼\n密碼\n確認密碼
    Click And Input    xpath=//android.widget.EditText[@hint='請輸入密碼']    654321
    Sleep    1s
    Click And Input    xpath=//android.widget.EditText[@hint='請輸入密碼']    654321
    Click Element    android:id/content
    Verify Element Enabled And Click    accessibility_id=完成
    Sleep    2s
    Wait Until Element Is Visible    accessibility_id=${title}
    Wait Until Page Contains Element    android:id/content
    Click Element    android=new UiSelector().className("android.widget.ImageView").instance(1)
    ${button_x}    Evaluate    ${Width} * 0.125
    ${button_y}    Evaluate    ${Height} * 0.3
    @{positions}    Create List    ${button_x}    ${button_y}
    Tap With Positions    ${100}    ${positions}
    Wait Until Element Is Visible    accessibility_id=帳號管理
    Verify Element Enabled And Click    accessibility_id=刪除帳號
    Wait Until Element Is Visible    accessibility_id=刪除帳號\n確定要刪除帳號嗎？\n刪除後您將遺失您原本的資料
    Click Element    accessibility_id=確認刪除
    Wait Until Element Is Visible    android=new UiSelector().description("登入")
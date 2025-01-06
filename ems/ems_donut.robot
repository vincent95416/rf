*** Settings ***
Resource    ../init.robot
Suite Setup    Suite Setup
Suite Teardown    Suite Teardown

**** Variables ***
@{widget_list}
...    power_donut_L
...    water_donut_L
...    oil_donut_L
...    gas_donut_L

*** Keywords ***
Suite Setup
    New Browser    browser=${browser}    headless=False
    New Context    viewport={'width': 1280, 'height': 720}    acceptDownloads=True
    New Page    ${url}    wait_until=load
    Log    Testing version ${VERSION} in ${ENV} environment

Suite Teardown
    Close Browser

Repeat building the donut 4 times
    FOR    ${widget}    IN    @{widget_list}
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=圓餅圖_btn
    Click With Options    id=dashboard_${widget}_div    force=True
    Sleep    1s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    ${widget}
    Select Options By    id=data_node_dev    value    ${org}-VTE-9999
    Click With Options    id=old_save_Btn    delay=100ms
    Get Text    id=status_msg_content    ==    已新增
    Sleep    3s
    Wait For Elements State    .wrapper    visible
    END


*** Test Cases ***
登入
    [Tags]    high_priority
    [Documentation]    輸入組織ID,帳號密碼並登入
    Wait For Load State    networkidle    timeout=30s
    Wait For Elements State    id=org_number    visible
    Fill Text    id=org_number    ${org}
    Fill Text    id=account    ${acc}
    Fill Text    id=password    ${pw}
    Click    id=loginBtn

建立一個測試用的label並開始widget編輯模式
    [Tags]    high_priority
    [Documentation]    打開widget編輯模式,以利後續測試
    Set Browser Timeout    10s
    Wait For Elements State    .wrapper    visible
    Click   id=next_page_url >>> id=btn_show_widget
    Wait For Elements State    id=next_page_url >>> id=add_page_btn    visible
    Hover    id=menu_aside
    Wait For Element And Click It    //p[@class='nav_page_text' and text()='QA']
    Wait For Elements State    .wrapper    visible
    Wait For Element And Click It    id=next_page_url >>> //span[@data-i18n='index.button.add_page_tag' and text()='新增頁籤']
    Wait For Elements State    id=iframe_device    visible
    Fill Text    id=iframe_device >>> input[id=page_txt]    圓餅圖
    Sleep    1s
    Click With Options    id=iframe_device >>> id=page_edit_submit    delay=100ms
    Sleep    1s
    Wait For Elements State    .wrapper    visible

12個折線圖建立
    Repeat Building The Donut 4 Times

驗證數值和文字
    @{titles}=    Get Elements    id=next_page_url >>> .main-title.zh-TW
    FOR    ${index}    ${widget}    IN ENUMERATE     @{widget_list}
        ${title}    Get Text    ${titles}[${index}]
        Should Be Equal    ${title}    ${widget}
    END
    @{values}    Get Elements    id=next_page_url >>> .chart-value
    FOR    ${value}    IN    @{values}
        Should Not Contain    ${value}    Na
    END

刪除標籤
    Handle Future Dialogs    accept
    Wait For Elements State    .wrapper    visible
    Click With Options    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[1]/div[2]/div[last()]    delay=500ms    clickCount=2
    Sleep    1s
    Click With Options    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[1]/div[2]/div[last()]/div    delay=500ms    force=True
    Sleep    1s
    Wait For Element And Click It    id=iframe_device >>> id=Del_page_Btn
    # alert 會被自動處理
    Wait For Elements State    .wrapper    visible
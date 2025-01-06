*** Settings ***
Resource    ../init.robot
Suite Setup    Suite Setup
Suite Teardown    Suite Teardown

*** Keywords ***
Suite Setup
    New Browser    browser=${browser}    headless=False
    New Context    viewport={'width': 1280, 'height': 720}    acceptDownloads=True
    New Page    ${url}    wait_until=load
    Log    Testing version ${VERSION} in ${ENV} environment

Suite Teardown
    Close Browser

*** Test Cases ***
登入
    [Tags]    high_priority
    [Documentation]    輸入組織ID,帳號密碼並登入
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
    Fill Text    id=iframe_device >>> input[id=page_txt]    即時看板
    Sleep    1s
    Click With Options    id=iframe_device >>> id=page_edit_submit    delay=100ms
    Sleep    1s
    Wait For Elements State    .wrapper    visible

建立數值看板並驗證數值
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=即時看板_btn
    Click With Options    id=dashboard_text_div    force=True
    Sleep    1s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    text
    Select Options By    id=data_node_dev    value    ${org}-VTE-9999
    Click With Options    id=old_save_Btn    delay=100ms
    Get Text    id=status_msg_content    ==    已新增
    Sleep    3s
    Scroll To Element    id=next_page_url >>> .dashboard-value
    ${value}    Get Text    id=next_page_url >>> .dashboard-value
    Should Not Contain    ${value}    Na
    Wait For Elements State    .wrapper    visible

建立日曆看板
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=即時看板_btn
    Click With Options    id=dashboard_date_div    force=True
    Sleep    1s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    date
    Click With Options    id=old_save_Btn    delay=100ms
    Get Text    id=status_msg_content    ==    已新增
    Sleep    3s

檢查日曆上的月週日是否顯示
    Scroll To Element    id=next_page_url >>> p[data-i18n='widget.kanban.date']
    ${m}    Get Text    id=next_page_url >>> h4[data-i18n='widget.kanban.month']
    ${w}    Get Text    id=next_page_url >>> h4[data-i18n='widget.kanban.week']
    ${d}    Get Text    id=next_page_url >>> p[data-i18n='widget.kanban.date']
    ${m_len}    Get Length    ${m}
    ${w_len}    Get Length    ${w}
    ${d_len}    Get Length    ${d}
    ${total_len}    Evaluate    ${m_len} + ${w_len} + ${d_len}
    Should Be True    ${total_len} > 6

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
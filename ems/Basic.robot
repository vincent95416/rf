*** Settings ***
Resource    ../init.robot
Suite Setup    Suite Setup
Suite Teardown    Suite Teardown

*** Keywords ***
Suite Setup
    New Browser    browser=${browser}    headless=False    slowMo=0
    New Context    viewport={'width': 1600, 'height': 900}    acceptDownloads=True
    New Page    ${url}
    Log    Testing version ${VERSION} in ${ENV} environment

Suite Teardown
    Close Browser

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

widget編輯模式
    [Tags]    high_priority
    [Documentation]    打開widget編輯模式,以利後續測試
    Set Browser Timeout    30s
    Wait For Elements State    css=body    visible
    Click   id=next_page_url >>> id=btn_show_widget
    Wait For Elements State    id=next_page_url >>> id=add_page_btn    visible
    Sleep    3s

新增頁面
    [Documentation]    在側邊菜單建立新page-robot並且建立robot2 label
    Hover    id=menu_aside
    Wait For Element And Click It    id=addmenu
    Wait For Elements State    id=iframe_device    visible
    Click   id=iframe_device >>> id=menu_txt
    Fill Text    id=iframe_device >>> input[id=menu_txt]    robot
    Click With Options   id=iframe_device >>> id=nav_ic_ac_div    force=True
    Click   id=iframe_device >>> id=go_toSet_page_btn
    Wait For Elements State    id=iframe_device >>> id=page_txt    visible
    Fill Text    id=iframe_device >>> id=page_txt    robot2
    Sleep    1s
    Click   id=iframe_device >>> id=page_edit_submit
    Wait For Elements State    id=next_page_url >>> .wrapper    visible

新增標籤
    [Documentation]    切換至robot page建立robot1 label
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Hover    id=menu_aside
    Wait For Element And Click It    //p[@class='nav_page_text' and text()='robot']
    Wait For Element And Click It    id=next_page_url >>> //span[@data-i18n='index.button.add_page_tag' and text()='新增頁籤']
    Wait For Elements State    id=iframe_device >>> css=body    visible
    Fill Text    id=iframe_device >>> input[id=page_txt]    robot1
    Sleep    1s
    Click With Options    id=iframe_device >>> id=page_edit_submit    delay=100ms
    Sleep    1s
    Wait For Elements State    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='robot1']    visible

標籤變更順序
    [Documentation]     改變兩個標籤的順序,將robot1移至前方
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Wait For Elements State    id=next_page_url >>> id=btn_area    visible
    Sleep    1s
    Mouse Move Relative To    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='robot1']
    Mouse Button    down
    Mouse Move Relative To    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='robot2']    -60
    Mouse Move Relative To    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='robot2']    0    5
    Mouse Move Relative To    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='robot2']    0    -10
    Mouse Button    up
    Get Text    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[1]/div[2]/div[1]/p    ==    robot1

新增widget
    [Tags]    edit_widget
    [Documentation]    建立一個電池儀表板widget
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=儀表板_btn
    Click With Options    id=dashboard_battery_div    force=True
    Sleep    1s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    大電池
    Fill Text    id=s_title    小電池
    Fill Text    id=note_info    電池
    Select Options By    id=data_node_dev    value   ${org}-VTE-9999
    Select Options By    id=data_node_nodes    value    ${node_id}
    Sleep    1s
    Click With Options    id=old_save_Btn    delay=100ms
    Sleep    1s
    Get Text    id=status_msg_content    ==    已新增
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Get Text    id=next_page_url >>> .chart-name    ==    電池
    Get Text    id=next_page_url >>> .sub-title    ==    小電池
    Get Text    id=next_page_url >>> .main-title.zh-TW    ==    大電池
    ${value}    Get Text    id=next_page_url >>> .chart-value
    Should Not Contain    ${value}    Na

編輯widget    #根據之後腳本設計需求再添增編輯的設定
    [Tags]    edit_widget
    [Documentation]    編輯此widget的備註
    Click With Options    id=next_page_url >>> .chart-value    clickCount=2    delay=100ms    force=True
    Sleep    1s
    Wait For Elements State    id=dashboard_battery_div    visible
    Get Attribute    id=dashboard_battery_div    class    ==    widget-group widget-selected
    Click With Options    id=set_btn    delay=500ms
    Clear And Input Text    id=note_info    V老大
    Click With Options    id=old_save_Btn    delay=500ms
    Sleep    3s
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Get Text    id=next_page_url >>> .chart-name    ==    V老大

複製widget        #複製後確認當前robot1 label的widget數量為2
    [Tags]    edit_widget
    [Documentation]    複製此widget在當前label
    Click With Options    id=next_page_url >>> ${widget_threedots}    delay=100ms
    Click With Options    id=next_page_url >>> //span[@data-i18n='widget.edit.copy' and text()='複製 Widget']    delay=100ms
    Wait For Elements State    id=next_page_url >>> .modal-content    visible
    Select Options By    id=next_page_url >>> id=widget_page        label    robot
    Select Options By    id=next_page_url >>> id=widget_page_tag    label    robot1
    Click With Options    id=next_page_url >>> id=widget_edit_submit    delay=100ms
    Sleep    2s
    @{widgets}    Get Elements    id=next_page_url >>> //span[@class='main-title zh-TW' and text()='大電池']
    Length Should Be    ${widgets}    2

複製後編輯
    [Tags]    edit_widget
    [Documentation]    編輯widget的備註
    @{widget}    Get Elements    id=next_page_url >>> .chart-value
    Click With Options    ${widget}[0]    clickCount=2
    Sleep    2s
    Get Attribute    id=儀表板_btn    class    ==    page-tag page_btn_click
    Get Attribute    id=dashboard_battery_div    class    ==    widget-group widget-selected
    Click With Options    id=set_btn    delay=100ms
    Clear And Input Text    id=note_info    小弟摩囉星，今年二十七
    Sleep    1s
    Click With Options    id=old_save_Btn    delay=100ms
    Sleep    1s
    Get Text    id=status_msg_content    ==    已儲存
    Sleep    1s
    Wait For Elements State    id=next_page_url >>> css=body    visible
    @{chart_name}    Get Elements    id=next_page_url >>> .chart-name
    ${first_chart_name}=    Get Text    ${chart_name}[0]
    Should Be Equal    ${first_chart_name}    小弟摩囉星，今年二十七

編輯後刪除
    [Tags]    edit_widget
    [Documentation]    刪除編輯後的widget
    @{widgets}    Get Elements    id=next_page_url >>> ${widget_threedots}
    Click With Options    ${widgets}[0]    delay=100ms    force=True
    @{delete}    Get Elements    id=next_page_url >>> .delete
    Click With Options    ${delete}[0]    delay=100ms
    Wait For Elements State    id=next_page_url >>> .modal-content    visible
    Wait For Elements State    id=next_page_url >>> id=delete_submit    stable
    Sleep    2s
    Click With Options    id=next_page_url >>> id=delete_submit    delay=500ms    clickCount=2
    Sleep    3s
    Should Not Contain    .chart-name    小弟摩囉星，今年二十七

複製到不同標籤    #複製到robot2 label,但是到後續Event pop案例中再來檢查
    [Tags]    edit_widget
    [Documentation]    複製widget到其他label
    Reload
    Set Browser Timeout    10s
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Click   id=next_page_url >>> id=btn_show_widget
    Wait For Elements State    id=next_page_url >>> id=add_page_btn    visible
    @{widgets}    Get Elements    id=next_page_url >>> ${widget_threedots}
    Click With Options    ${widgets}[0]    delay=100ms    force=True
    Sleep    2s
    Click With Options    id=next_page_url >>> //span[@data-i18n='widget.edit.copy' and text()='複製 Widget']    delay=100ms    force=True
    Wait For Elements State    id=next_page_url >>> .modal-content    visible
    Select Options By    id=next_page_url >>> id=widget_page        label    robot
    Select Options By    id=next_page_url >>> id=widget_page_tag    label    robot2
    Click With Options    id=next_page_url >>> id=widget_edit_submit    delay=100ms
    Get Text    id=status_msg_content    ==    已複製

複製到不同頁面    #複製到QA page並檢查測試1 label中是否有widget
    [Tags]    edit_widget
    [Documentation]    複製到其他page
    Reload
    Set Browser Timeout    10s
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Click   id=next_page_url >>> id=btn_show_widget
    Wait For Elements State    id=next_page_url >>> id=add_page_btn    visible
    @{widgets}    Get Elements    id=next_page_url >>> ${widget_threedots}
    Click With Options    ${widgets}[0]    delay=100ms    force=True
    Sleep    2s
    Click With Options    id=next_page_url >>> //span[@data-i18n='widget.edit.copy' and text()='複製 Widget']    delay=100ms    force=True
    Wait For Elements State    id=next_page_url >>> .modal-content    visible
    Wait For Elements State    id=next_page_url >>> .modal-title    visible
    Get Text    id=next_page_url >>> .modal-title    ==    複製 Widget
    Select Options By    id=next_page_url >>> id=widget_page        label    QA
    Select Options By    id=next_page_url >>> id=widget_page_tag    label    robot1
    Click With Options    id=next_page_url >>> id=widget_edit_submit    delay=100ms
    Sleep    2s
    Get Text    id=status_msg_content    ==    已複製
    #到QA page檢查widget複製結果,後續執行搬移
    Hover    id=menu_aside
    Wait For Element And Click It    //p[@class='nav_page_text' and text()='QA']
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Click With Options    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='robot1']    clickCount=2
    Get text    id=next_page_url >>> .main-title.zh-TW    ==    大電池

搬移到同一頁面
    #原頁(QA page)搬移,確認widget
    [Tags]    edit_widget
    [Documentation]    切換到QA page並此做page搬移
    Click With Options    id=next_page_url >>> ${widget_threedots}    delay=100ms
    Click With Options    id=next_page_url >>> //span[@data-i18n='widget.edit.move' and text()='搬移 Widget']    delay=100ms
    Wait For Elements State    id=next_page_url >>> .modal-content    visible
    Select Options By    id=next_page_url >>> id=widget_page        label    QA
    Select Options By    id=next_page_url >>> id=widget_page_tag    label    robot1
    Click With Options    id=next_page_url >>> id=widget_edit_submit    delay=100ms
    Get Text    id=status_msg_content    ==    已搬移
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    @{widgets}    Get Elements    id=next_page_url >>> .main-title.zh-TW
    ${battery}=    Set Variable    False
    FOR    ${element}    IN    @{widgets}
    ${text}=    Get Text    ${element}
    ${found}=    Evaluate    '大電池' in '${text}'
    # 如果找到就跳出循環
    Run Keyword If    ${battery}    Exit Fo－r Loop
    END

搬移到不同頁面    #搬回robot-robot1,並確認widget
    [Tags]    edit_widget
    [Documentation]    搬移回robot page後刪除
    Click With Options    id=next_page_url >>> ${widget_threedots}    delay=100ms
    Click With Options    id=next_page_url >>> //span[@data-i18n='widget.edit.move' and text()='搬移 Widget']    delay=100ms
    Wait For Elements State    id=next_page_url >>> .modal-content    visible
    Select Options By    id=next_page_url >>> id=widget_page        label    robot
    Select Options By    id=next_page_url >>> id=widget_page_tag    label    robot1
    Click With Options    id=next_page_url >>> id=widget_edit_submit    delay=100ms
    Get Text    id=status_msg_content    ==    已搬移
    Wait For Elements State    id=next_page_url    visible
    Hover    id=menu_aside
    Wait For Element And Click It    //p[@class='nav_page_text' and text()='robot']
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Click With Options    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='robot1']    clickCount=2
    @{widgets}    Get Elements    id=next_page_url >>> //span[@class='main-title zh-TW' and text()='大電池']
    Length Should Be   ${widgets}    2

複製,搬移後刪除    #刪除複製後及搬移後的widgets
    [Tags]    edit_widget
    [Documentation]    刪除此label的兩個widget(複製後與搬移後)
    @{widget}    Get Elements    id=next_page_url >>> ${widget_threedots}
    Click With Options    ${widget}[0]    delay=100ms
    @{delete}    Get Elements    id=next_page_url >>> .delete
    Click With Options    ${delete}[0]    delay=100ms
    Wait For Elements State    id=next_page_url >>> .modal-content    visible
    Wait For Elements State    id=next_page_url >>> id=delete_submit    stable
    Click With Options    id=next_page_url >>> id=delete_submit    delay=500ms
    Sleep    3s
    Click With Options    id=next_page_url >>> ${widget_threedots}    delay=100ms
    Click With Options    id=next_page_url >>> .delete    delay=100ms
    Wait For Elements State    id=next_page_url >>> .modal-content    visible
    Wait For Elements State    id=next_page_url >>> id=delete_submit    stable
    Click With Options    id=next_page_url >>> id=delete_submit    delay=500ms
    #兩個widgets刪除後並確認頁面
    Wait For Elements State    id=next_page_url >>> .widget-group.widget-s.widget-edit.ui-sortable-handle    hidden

widget power bar
    [Tags]    multiple widget
    [Documentation]    建立電壓長條圖widget
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=長條圖_btn
    Click With Options    id=dashboard_power_bar_div    force=True
    Sleep    1s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    大電壓
    Fill Text    id=s_title    小電壓
    Fill Text    id=note_info    電壓
    Select Options By    id=data_node_dev    value    ${org}-VTE-9999
    Select Options By    id=data_node_nodes    value    ${node_id}
    Select Options By    id=chart_data_nodes_dev    value    ${org}-VTE-9999
    Select Options By    id=chart_data_nodes_nodes    value    ${node_id}
    Click With Options    xpath=//input[@onclick="add_nodes('chart_data_nodes')"]    delay=100ms
    Wait For Elements State    .select_item_div    visible
    Get Text    xpath=/html/body/div[4]/div/div[2]/div[4]/table/tr[16]/td/div/div/span    ==    ${org}-VTE-9999.${node_id}
    Wait For Elements State    .select_item_del    visible
    Select Options By    id=data_search_type    label    天
    Sleep    1s
    Click With Options    id=old_save_Btn    delay=100ms
    Sleep    3s
    Get Text    id=status_msg_content    ==    已新增
    Sleep    3s
    ${value}    Get Text    id=next_page_url >>> .chart-value
    Should Not Contain    ${value}    Na
    Wait For Elements State    id=next_page_url >>> .wrapper    visible

widget env area
    [Tags]    multiple widget
    [Documentation]    建立環境面積圖widget
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=面積圖_btn
    Click With Options    id=dashboard_env_area_div    force=True
    Sleep    1s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    大環境
    Fill Text    id=s_title    小環境
    Fill Text    id=note_info    環境
    Select Options By    id=data_node_dev    value    ${org}-VTE-9999
    Select Options By    id=data_node_nodes    value    ${node_id}
    Select Options By    id=chart_data_nodes_dev    value    ${org}-VTE-9999
    Select Options By    id=chart_data_nodes_nodes    value    ${node_id}
    Click With Options    xpath=//input[@onclick="add_nodes('chart_data_nodes')"]    delay=100ms
    Wait For Elements State    .select_item_div    visible
    Get Text    xpath=/html/body/div[4]/div/div[2]/div[4]/table/tr[16]/td/div/div/span    ==    ${org}-VTE-9999.${node_id}
    Wait For Elements State    .select_item_del    visible
    Select Options By    id=data_search_type    label    月
    Sleep    1s
    Click With Options    id=old_save_Btn    delay=100ms
    Sleep    3s
    Get Text    id=status_msg_content    ==    已新增
    Sleep    3s
    Scroll To Element    id=next_page_url >>> css=span[databind="Orange-VTE-9999NODEVTP-0001_dashboard_env_area"]
    ${value}    Get Text    id=next_page_url >>> css=span[databind="Orange-VTE-9999NODEVTP-0001_dashboard_env_area"]
    Should Not Contain    ${value}    Na
    Wait For Elements State    id=next_page_url >>> .wrapper    visible

變更widget順序
    [Tags]    multiple widget
    [Documentation]    拖曳並改變widget的順序
    Mouse Move Relative To    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[2]/div[2]/div[1]
    Sleep    1s
    Mouse Button    down
    Sleep    1s
    Mouse Move Relative To    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[2]/div[1]/div[1]
    Sleep    1s
    Mouse Button    up
    Sleep    1s
    @{widget}    Get Elements    id=next_page_url >>> .sub-title
    ${text}    Get Text    ${widget}[0]
    Should Be Equal    ${text}    小環境

widget people line
    [Tags]    multiple widget
    [Documentation]    建立功率因數折線圖widget
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=折線圖_btn
    Click With Options    id=dashboard_people_line_div    force=True
    Sleep    1s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    大功率因數
    Fill Text    id=s_title    小功率因數
    Fill Text    id=note_info    功率因數
    Select Options By    id=data_node_dev    value    ${org}-VTE-9999
    Select Options By    id=data_node_nodes    value    ${node_id}
    Select Options By    id=chart_data_nodes_dev    value    ${org}-VTE-9999
    Select Options By    id=chart_data_nodes_nodes    value    ${node_id}
    Click With Options    xpath=//input[@onclick="add_nodes('chart_data_nodes')"]    delay=100ms
    Wait For Elements State    .select_item_div    visible
    Get Text    xpath=/html/body/div[4]/div/div[2]/div[4]/table/tr[16]/td/div/div/span    ==    ${org}-VTE-9999.${node_id}
    Wait For Elements State    .select_item_del    visible
    Select Options By    id=data_search_type    label    年
    Sleep    1s
    Click With Options    id=old_save_Btn    delay=100ms
    Sleep    3s
    Get Text    id=status_msg_content    ==    已新增
    Sleep    3s
    Scroll To Element    id=next_page_url >>> css=span[databind="Orange-VTE-9999NODEVTP-0001_dashboard_people_line"]
    ${value}    Get Text    id=next_page_url >>> css=span[databind="Orange-VTE-9999NODEVTP-0001_dashboard_people_line"]
    Should Not Contain    ${value}    Na
    Wait For Elements State    id=next_page_url >>> .wrapper    visible

widget water donut
    [Tags]    multiple widget
    [Documentation]    建立濕度圓餅圖widget
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=圓餅圖_btn
    Click With Options    id=dashboard_water_donut_L_div    force=True
    Sleep    1s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    大濕度
    Fill Text    id=s_title    小濕度
    Fill Text    id=note_info    濕度
    Select Options By    id=data_node_1_dev    value    ${org}-VTE-9999
    Select Options By    id=data_node_1_nodes    value    ${node_id}
    Sleep    1s
    Click With Options    id=old_save_Btn    delay=100ms
    Sleep    3s
    Get Text    id=status_msg_content    ==    已新增
    Sleep    3s
    Scroll To Element    id=next_page_url >>> .chart-value.donut
    ${value}    Get Text    id=next_page_url >>> .chart-value.donut
    Should Not Contain    ${value}    Na
    Wait For Elements State    id=next_page_url >>> .wrapper    visible

widget kanban
    [Tags]    multiple widget
    [Documentation]    建立數值即時看板
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=即時看板_btn
    Click With Options    id=dashboard_text_div    force=True
    Sleep    1s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    大數值
    Fill Text    id=s_title    小數值
    Select Options By    id=data_node_dev    value    ${org}-VTE-9999
    Select Options By    id=data_node_nodes    value    ${node_id}
    Sleep    1s
    Click With Options    id=old_save_Btn    delay=100ms
    Sleep    3s
    Get Text    id=status_msg_content    ==    已新增
    Sleep    3s
    Scroll To Element    id=next_page_url >>> .dashboard-value
    ${value}    Get Text    id=next_page_url >>> .dashboard-value
    Should Not Contain    ${value}    Na
    Wait For Elements State    id=next_page_url >>> .wrapper    visible

widget report
    [Tags]    multiple widget
    [Documentation]    建立報表
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=報表_btn
    Click With Options    id=L_cardType_widgets    force=True
    Sleep    1s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    大報表
    Fill Text    id=s_title    小報表
    Select Options By    id=data_node_dev    value    ${org}-VTE-9999
    Select Options By    id=data_node_nodes    value    ${node_id}
    Sleep    1s
    Click With Options    id=old_save_Btn    delay=100ms
    Sleep    3s
    Get Text    id=status_msg_content    ==    已新增
    Sleep    3s
    Wait For Elements State    id=next_page_url >>> .wrapper    visible

widget elevator
    [Tags]    multiple widget
    [Documentation]    建立電梯
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=電梯_btn
    Click With Options    id=elevator_div    force=True
    Sleep    1s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    大電梯
    Fill Text    id=s_title    小電梯
    Select Options By    id=data_node_dev    value    625701012333A6E1_elevator_1
    Sleep    1s
    Click With Options    id=old_save_Btn    delay=100ms
    Get Text    id=status_msg_content    ==    已新增
    Sleep    3s
    Wait For Elements State    id=next_page_url >>> .wrapper    visible

widget airConditioner
    [Tags]    multiple widget
    [Documentation]    建立冷氣
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=冷氣_btn
    Click With Options    id=airConditioner_div    force=True
    Sleep    1s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    大冷氣
    Fill Text    id=s_title    小冷氣
    Select Options By    id=data_node_dev    value    ${org}-VTE-9999
    Select Options By    id=data_node_nodes    value    ${node_id}
    Sleep    1s
    Click With Options    id=old_save_Btn    delay=100ms
    Sleep    3s
    Get Text    id=status_msg_content    ==    已新增
    Sleep    3s
    Wait For Elements State    id=next_page_url >>> .wrapper    visible

新增平面圖
    [Tags]    multiple widget
    [Documentation]    建立平面圖
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=平面圖_btn
    #Click With Options    id=XL_cardType_widgets    force=True
    #現在onclick事件有bug,無法選中XL的平面圖widget,因此改執行下兩行程式碼
    Click With Options    xpath=/html/body/div[3]/div[2]/div[1]/div/div/div[1]/p[2]    delay=100ms
    Get Attribute    id=Map_L_div    class    ==    widget-group widget-donut widget-selected
    Sleep    2s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    大平面圖
    Fill Text    id=s_title    小平面圖
    Click With Options    .btn-clear.d-flex.flex-row.align-items-center.f-16-600.c-blue.mt-2.mb-3    delay=100ms
    Wait For Elements State    id=iframe_map >>> css=body    visible
    Upload File By Selector    id=iframe_map >>> input#file2    53W8K9.jpg
    Click With Options    id=iframe_map >>> id=upload_submit    delay=100ms
    Get Text    id=status_msg_content    ==    已上傳
    Get Attribute    id=iframe_map >>> id=nomap_icon    class    ==    icon icon-100 icon-nomap d-none
    Get Text    id=iframe_map >>> id=map_name_show    ==    53W8K9.jpg
    #icon新增
    Wait For Element And Click It    id=iframe_map >>> id=add_widget_btn
    Wait For Elements State    id=iframe_map >>> id=iframe_map_widget >>> css=body    visible
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=next_widget_btn    delay=300ms
    Get Attribute    id=iframe_map >>> id=iframe_map_widget >>> id=step2_title    class    ==    path active
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=data_node_dev    value    ${org}-VTE-9999
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=data_node_nodes    value    ${node_id}
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=add_btn    delay=100ms
    Get Text    id=status_msg_content    ==    已加入
    Sleep    1s
    ${icon1}    Get Element    id=iframe_map >>> css=span[databind='${org}-VTE-9999NODE${node_id}']
    Hover    ${icon1}
    Wait For Elements State    id=iframe_map >>> .map_widget_hover    visible
    ${nowrap1}    Get text    id=iframe_map >>> xpath=/html/body/div[2]/div[2]/div/div[2]/div[2]/div[2]/span[2]
    Should Contain    ${nowrap1}    ${node_id}
    Sleep    1s
    Click With Options    id=iframe_map >>> id=Save_Btn    delay=100ms
    Get Text    id=status_msg_content    ==    已儲存
    Click With Options    id=old_save_Btn    delay=100ms
    Get Text    id=status_msg_content    ==    已新增
    Sleep    3s

編輯平面圖
    [Tags]    multiple widget
    [Documentation]    編輯平面圖
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Scroll To Element    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[2]/div[9]/div[1]/div[2]/button
    Click With Options    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[2]/div[9]/div[1]/div[2]/button    delay=100ms
    Click    id=next_page_url >>> xpath=//span[@data-i18n='widget.edit.map']
    Wait For Elements State    id=iframe_map >>> css=body    visible
    Upload File By Selector    id=iframe_map >>> input#file2    90909.jpg
    Sleep    1s
    Click With Options    id=iframe_map >>> id=upload_submit    delay=100ms
    Sleep    1s
    Get Text    id=status_msg_content    ==    已上傳
    Wait For Elements State    id=iframe_map >>> id=map_name_show    stable
    Get Text    id=iframe_map >>> id=map_name_show    ==    90909.jpg
    #icon處理,刪除、編輯等動作
    Wait For Elements State    id=iframe_map >>> .widget-box    visible
    Click With Options    id=iframe_map >>> .widget-box    delay=500ms    button=right
    Wait For Elements State    id=iframe_map >>> .menu    visible
    Click With Options    id=iframe_map >>> id=Edit_btn
    Wait For Elements State    id=iframe_map >>> id=iframe_map_widget >>> id=widget_demo_view_area    visible
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=next_widget_btn    delay=300ms
    Fill Text    id=iframe_map >>> id=iframe_map_widget >>> id=unit    Q
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=add_btn    delay=100ms
    Get Text    id=status_msg_content    ==    已加入
    Get Text    id=iframe_map >>> xpath=/html/body/div[2]/div[2]/div/div[2]/div/span[2]    ==    Q
    Click With Options    id=iframe_map >>> .widget-box    delay=500ms    button=right
    Wait For Elements State    id=iframe_map >>> .menu    visible
    Click With Options    id=iframe_map >>> id=Copy_btn
    Get Text    id=status_msg_content    ==    已複製
    @{box}    Get Elements    id=iframe_map >>> .widget-box
    Length Should Be    ${box}    2
    Click With Options    id=iframe_map >>> xpath=/html/body/div[2]/div[2]/div/div[2]/div/span[2]    delay=500ms    button=right    force=True
    Wait For Elements State    id=iframe_map >>> .menu    visible
    Click With Options    id=iframe_map >>> id=Del_btn
    @{box_after_del}    Get Elements    id=iframe_map >>> .widget-box
    Length Should Be    ${box_after_del}    1
    Click With Options    id=iframe_map >>> id=Save_Btn    delay=100ms
    Get Text    id=status_msg_content    ==    已儲存
    Sleep    3s

刪除標籤
    [Documentation]     刪除robot1 label
    Handle Future Dialogs    accept
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Click With Options    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[1]/div[2]/div[1]/div    delay=500ms    force=True
    Sleep    1s
    Wait For Element And Click It    id=iframe_device >>> id=Del_page_Btn
    # alert 會被自動處理
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Wait For Elements State    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='Lestrade']    detached

告警觸發,事件管理    #修改widget致告警事件觸發,檢查pop up後到事件管理驗證
    [Tags]    high_priority
    [Documentation]    切換到robot2 label驗證先前的複製結果,並觸發告警事件,後續到事件管理檢查
    #Click With Options    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='robot2']    clickCount=2
    Wait For Elements State    id=next_page_url >>> .chart-value    visible
    Click With Options    id=next_page_url >>> .chart-value    clickCount=2    delay=100ms    force=True
    Sleep    1s
    Wait For Elements State    id=dashboard_battery_div    visible
    Get Attribute    id=dashboard_battery_div    class    ==    widget-group widget-selected
    Click With Options    id=set_btn    delay=500ms
    Clear And Input Text    id=baseline_val    1
    Click    id=trigger-1
    Fill Text    id=alert_note    無保請回
    Click With Options    id=old_save_Btn    delay=500ms
    Get Text    id=status_msg_content    ==    已儲存
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Sleep    3s
    Wait For Elements State    id=eventPop_iframe    visible    60s
    Wait For Elements State    id=eventPop_iframe >>> id=all_info_count    stable
    ${text}    Get Text    id=eventPop_iframe >>> id=event_alarm_msg
    Sleep    3s
    #Should Contain    ${text}    無保請回
    #檢查告警內容是否包含預期文字,否則點下一頁找尋,最多五次
    ${page}    Set Variable    0
    FOR    ${index}    IN RANGE    6
        ${text}    Get Text    id=eventPop_iframe >>> id=event_alarm_msg
        ${result}    Run Keyword And Ignore Error    Should Contain    ${text}    無保請回
        Run Keyword If    '${result[0]}' == 'PASS'    Exit For Loop
        Run Keyword If    '${result[0]}' == 'FAIL'    Click    id=eventPop_iframe >>> .icon.icon-event-pop-after.icon-28
        Run Keyword If    '${result[0]}' == 'FAIL'    Sleep    1s
        Run Keyword If    '${result[0]}' == 'FAIL'    Set Variable    ${page}    ${page} + 1
    END
    Sleep    1s
    Click With Options    id=eventPop_iframe >>> id=widget_btn    delay=300ms
    Hover    id=menu_aside
    Wait For Element And Click It    id=event_list
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Get Text    id=next_page_url >>> xpath=/html/body/main/div[2]/ul/li[1]/div[1]/div[2]/div[1]/div[2]/span[2]    ==    未處理
    Get Text    id=next_page_url >>> xpath=/html/body/main/div[2]/ul/li[1]/div[1]/div[2]/div[2]/span[4]    ==    ${text}
    Click With Options    id=next_page_url >>> .ev-link    delay=100ms
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Get Attribute    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[2]/div    class    ==    widget-group widget-s widget-view event-widget
    Click    id=next_page_url >>> .more-btn more-alarm-close
    Wait For Elements State    id=next_page_url >>> .trigger-menu list-group d-block    visible
    Click With Options    id=next_page_url >>> //span[@data-i18n='widget.edit.trigger_close' and text()='關閉告警']
    Get Text    id=status_msg_content    ==    已關閉告警

投影管理
    [Documentation]    投影管理,新增編輯刪除等操作
    Hover    id=menu_aside
    Wait For Element And Click It    id=signage_list
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Click With Options    id=next_page_url >>> id=add_widget_div    delay=100ms
    Sleep    1s
    Get Attribute    id=add_signage_modal    class    ==    modal fade show
    Fill Text    id=add_signage_title    robotProjector
    Click With Options    id=sigAdd_submit    delay=100ms
    Get Text    id=status_msg_content    ==    已新增
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Sleep    3s
    Click With Options    id=next_page_url >>> text="robotProjector"    delay=100ms    clickCount=2    force=True
    Wait For Elements State    .signage-edit-body    visible
    Click    span[data-i18n="signage.edit.tag.set"]
    Click With Options    //button[@onclick='save_signage()']    delay=100ms
    Wait For Elements State    id=status_msg_content    visible
    Get Text    id=status_msg_content    ==    已儲存
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Click With Options    id=next_page_url >>> xpath=/html/body/div[2]/div[2]/div[last()]/div/div[2]    delay=100ms
    Wait For Elements State    id=next_page_url >>> .edit-menu:not(.d-none)    visible
    Click With Options    id=next_page_url >>> //div[@class='edit-menu' and not(contains(@class, 'd-none'))]//p[@class='c-danger' and text()='刪除投影']    delay=100ms
    Wait For Elements State    .index-body.modal-open    visible
    Click With Options    //button[@onclick='delSig_confirm_submit()']    delay=100ms
    Get Text    id=status_msg_content    ==    已刪除

報表管理
    [Documentation]    到報表管理建立報表做建立,編輯,刪除動作以及下載項目(歷史數據,報表)
    Hover    id=menu_aside
    Wait For Element And Click It    id=report_list
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Click With Options    id=next_page_url >>> id=add_widget_div
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Fill Text    id=next_page_url >>> id=devReport_Title_txt    robot_repo
    Click With Options    id=next_page_url >>> id=sava_report_btn    delay=100ms
    Get Text    id=status_msg_content    ==    完成
    Sleep    1s
    ${last_repo}    Get Element    id=next_page_url >>> xpath=/html/body/div[2]/div[2]/div[last()]/p[1]
    ${last_title}    Get Text    ${last_repo}
    Should Be Equal    ${last_title}    robot_repo
    Click With Options    ${last_repo}    delay=500ms
    Select Options By    id=next_page_url >>> id=def_list    value    table_chart
    Select Options By    id=next_page_url >>> id=chart_list    value    ColumnChart
    Select Options By    id=next_page_url >>> id=search_type    value    day_report
    Sleep    1s
    Click With Options    id=next_page_url >>> id=add-item-dropdown    delay=100ms
    Wait For Elements State    id=next_page_url >>> id=search_set_area    visible
    Fill Text    id=next_page_url >>> id=Table_title    robot_col
    Click    id=next_page_url >>> id=dropdown_devs
    Get Attribute    id=next_page_url >>> id=dropdown_devs_list    class    ==    dropdown-menu menu-scroll show
    Click With Options    id=next_page_url >>> li[onclick="select_devs('${org}-VTE-9999')"]    delay=100ms
    Get Text    id=next_page_url >>> id=dropdown_devs_btn    ==    ${org}-VTE-9999
    Click    id=next_page_url >>> id=dropdown_nodes
    Get Attribute    id=next_page_url >>> id=dropdown_nodes_list    class    ==    dropdown-menu menu-scroll show
    Click With Options    id=next_page_url >>> li[onclick="select_nodes('${node_id}')"]    delay=100ms
    Get Text    id=next_page_url >>> id=dropdown_nodes_btn    ==    ${node_id}
    Click    id=next_page_url >>> id=dropdown_statisticsType
    Get Attribute    id=next_page_url >>> id=dropdown_statisticsType_list    class    ==    dropdown-menu menu-scroll show
    Click With Options    id=next_page_url >>> li[onclick="select_statistics_type('max')"]    delay=100ms
    Get Text    id=next_page_url >>> id=dropdown_statisticsType_btn    ==    最大值
    Click With Options    id=next_page_url >>> id=Add_select_btn    delay=100ms
    Get Text    id=status_msg_content    ==    已新增
    Wait For Elements State    id=next_page_url >>> .item-title-row.d-flex.justify-content-between    visible
    Get Text    id=next_page_url >>> .d-inline.item-title    ==    項目一
    Wait For Elements State    id=next_page_url >>> id=chart    visible
    Wait For Elements State    id=next_page_url >>> id=data_table    visible
    Get Text    id=next_page_url >>> xpath=/html/body/div[2]/div[1]/div[3]/div[2]/table/thead/tr/th[2]    ==    robot_col
    Click With Options    id=next_page_url >>> id=export_report    delay=500ms
    Wait For Elements State    id=next_page_url >>> .dropdown-menu.report.dropdown-menu-right.show    visible
    #在15秒內每3秒檢查下載狀態
    Sleep    1s
    ${download_1}=    Download    id=next_page_url >>> a[data-i18n='report.button.xls']
    Wait Until Keyword Succeeds    15s    3s    Should Be Equal    ${download_1.state}    finished
    #歷史資料下載
    Click With Options    id=next_page_url >>> id=sava_report_btn    delay=100ms
    Get Text    id=status_msg_content    ==    完成
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Click With Options    id=next_page_url >>> id=Button1    delay=100ms
    Wait For Elements State    id=raw_iframe    visible
    Select Options By    id=raw_iframe >>> id=devs_list    value    ${org}-VTE-9999
    ${download_2}=    Download    id=raw_iframe >>> id=sava_report_btn
    Wait Until Keyword Succeeds    15s    3s    Should Be Equal    ${download_2.state}    finished
    Click With Options    id=raw_iframe >>> input[onclick="close_repair_info()"]    delay=500ms    force=True
    Wait For Elements State    id=raw_data_block    hidden
    #刪除
    ${report_id}    Get Attribute    id=next_page_url >>> xpath=/html/body/div[2]/div[2]/div[last()]    onclick
    Click With Options    id=next_page_url >>> xpath=/html/body/div[2]/div[2]/div[last()]/div/div[2]    delay=200ms
    Sleep    1s
    Click    id=next_page_url >>> xpath=/html/body/div[2]/div[2]/div[last()]/div/div[3]/p
    Sleep    1s
    Wait For Elements State    button[onclick="delSig_confirm_submit()"]    visible
    Click With Options    button[onclick="delSig_confirm_submit()"]    delay=200ms
    Check Onclick Hidden    id=next_page_url >>> .block-item    ${report_id}

虛擬設備
    [Documentation]    系統設定>設備管理,虛擬設備的建立編輯和刪除
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Hover    id=menu_aside
    Wait For Element And Click It    id=Setting_Btn
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Wait For Element And Click It    id=next_page_url >>> a[href="#/devices"]
    Click With Options    id=next_page_url >>> .btn.btn-blue.fill-white.f-14-600    delay=100ms
    Get Attribute    id=next_page_url >>> id=deviceVirtualCreateOffcanvas    class    ==    offcanvas offcanvas-end show
    Fill Text    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[2]/input    devrobot
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[3]/div/div[1]/button    delay=100ms
    Get Attribute    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[3]/div/div[1]/button    class    ==    btn btn-gray dropdown-icon no-hover f-16-400 text-placeholder show
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[3]/div/div[1]/ul/li/button[1]    delay=100ms
    Get Text    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[3]/div/div[1]/button    ==    測試
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[4]/div/div[1]/button    delay=100ms
    Get Attribute    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[4]/div/div[1]/button    class    ==    btn btn-gray dropdown-icon no-hover f-16-400 text-placeholder show
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[4]/div/div[1]/ul/li[1]/button[1]    delay=100ms
    Get Text    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[4]/div/div[1]/button    ==    QA
    Click With Options    id=next_page_url >>> id=addVirtualDevice    delay=100ms
    Get Attribute    id=next_page_url >>> id=select-device-Modal    class    ==    modal fade bd-example-modal-lg show
    Click    id=next_page_url >>> id=${opt1}
    Click    id=next_page_url >>> id=${opt2}
    Wait For Elements State    id=next_page_url >>> text="加入"    enabled
    Click With Options    id=next_page_url >>> text="加入"    delay=100ms
    Get Text        id=next_page_url >>> xpath=/html/body/div/div[10]/div/div/p    ==    已加入
    Wait For Elements State    id=next_page_url >>> .col-6.fw-bold.mt-4.mb-2    visible
    Should Not Contain    id=next_page_url >>> .bindNotice    至少綁定兩個設備。
    Wait For Elements State    id=next_page_url >>> xpath=/html/body/div/div[6]/div[3]/button    enabled
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[3]/button    delay=100ms
    Get Text        id=next_page_url >>> xpath=/html/body/div/div[10]/div/div/p    ==    已新增
    Wait For Elements State    id=next_page_url >>> xpath=/html/body/div/div[2]/section[2]/div[2]/div/table    stable
    Sleep    1s
    @{edit}    Get Elements    id=next_page_url >>> .btn.btn-outline-primary.border-0.f-14-600
    Click With Options    ${edit}[0]    delay=500ms
    Wait For Elements State    id=next_page_url >>> .offcanvas.offcanvas-end.show    visible
    Fill Text    id=next_page_url >>> xpath=/html/body/div/div[3]/div[2]/form/div/div[2]/input    devicerobot
    Click With Options    id=next_page_url >>> .col-auto.btn.btn-outline-primary.fw-semibold.mb-0    delay=100ms
    Get Attribute    id=next_page_url >>> id=nodeEditOffcanvas    class    ==    offcanvas offcanvas-end show
    Fill Text    id=next_page_url >>> xpath=/html/body/div/div[4]/div[2]/form/div/div[2]/input    noderobot
    Click With Options    id=next_page_url >>> id=dropdown-device    delay=100ms
    Wait For Elements State    id=next_page_url >>> .dropdown-menu.overflow-hidden.show    visible
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[4]/div[2]/form/div/div[4]/div/div[1]/div[1]/ul/li[last()]    delay=100ms
    Click With Options    id=next_page_url >>> id=dropdown-node    delay=100ms
    Wait For Elements State    id=next_page_url >>> .dropdown-menu.overflow-hidden.show    visible
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[4]/div[2]/form/div/div[4]/div/div[1]/div[2]/ul/li[3]/a    delay=100ms
    Click With Options    id=next_page_url >>> id=dropdown-type    delay=100ms
    Click With Options    id=next_page_url >>> text="數值"    delay=100ms
    Fill Text    id=next_page_url >>> input[name="parameter-number"]    1
    Wait For Elements State    id=next_page_url >>> xpath=/html/body/div/div[4]/div[3]/button    enabled
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[4]/div[3]/button    delay=500ms
    Get Text    id=next_page_url >>> xpath=/html/body/div/div[10]/div/div/p    ==    已新增
    Sleep    3s
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[3]/div[3]/button    delay=100ms    force=True
    Wait For Elements State    id=next_page_url >>> xpath=/html/body/div/div[10]/div/div/p    stable
    Get Text    id=next_page_url >>> xpath=/html/body/div/div[10]/div/div/p    ==    已儲存
    Sleep    1s
    @{delete}    Get Elements    id=next_page_url >>> .btn.btn-outline-danger.border-0.f-14-600
    Click With Options    ${delete}[0]    delay=500ms
    Sleep    1s
    Get Attribute    id=next_page_url >>> id=checkDeleteModal    class    ==    modal fade show
    Get Text    id=next_page_url >>> xpath=/html/body/div[1]/div[9]/div/div/div[2]/p/span    ==    devicerobot
    Click With Options    id=next_page_url >>> .f-14-600.btn.btn-delete.btn-172-44    delay=100ms
    Wait For Elements State    id=next_page_url >>> css=td:has-text("devicerobot")    detached    5s

刪除頁面
    Reload
    Wait For Elements State    .wrapper    visible
    Hover    id=menu_aside
    Wait For Element And Click It    id=Setting_Btn
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Hover    css=body
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[2]/ul/li[2]    delay=100ms
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Wait For Elements State    id=next_page_url >>> .table.table-hover    stable
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[2]/section[2]/div[2]/div/table/tbody/tr[last()]/td[4]/div/button[2]    delay=500ms
    Wait For Elements State    id=next_page_url >>> .modal.fade.show    visible
    Click With Options    id=next_page_url >>> xpath=/html/body/div[1]/div[4]/div/div/div[2]/div/button[1]
    Get Text    id=next_page_url >>> xpath=/html/body/div/div[5]/div/div    ==    已刪除

建立系統權限為1和2的管理者
    Reload
    Hover    id=menu_aside
    Wait For Element And Click It    id=Setting_Btn
    Wait For Elements State    id=next_page_url >>> .account-container    visible
    Click With Options    id=next_page_url >>> .btn.btn-blue.fill-white.f-14-600    delay=100ms
    Fill Text    id=next_page_url >>> id=account    robot_admin1
    Fill Text    id=next_page_url >>> id=name    robot_name1
    Fill Text    id=next_page_url >>> id=tel    0987654321
    Fill Text    id=next_page_url >>> id=email    q@q.q
    Click    id=next_page_url >>> id=department
    Get Attribute    id=next_page_url >>> id=department    aria-expanded    ==    true
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[5]/div/div[1]/ul/li/a    delay=300ms    force=True
    Click    id=next_page_url >>> id=title
    Get Attribute    id=next_page_url >>> id=title    aria-expanded    ==    true
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[6]/div/div[1]/ul/li[2]/a    delay=300ms    force=True
    Select Options By    id=next_page_url >>> id=system-access    value    1
    Click    id=next_page_url >>> xpath=/html/body/div/div[6]/div[3]/button
    Sleep    1s
    Fill Text    id=next_page_url >>> id=password    1
    Fill Text    id=next_page_url >>> id=passwordChcek    1
    Click    id=next_page_url >>> xpath=/html/body/div/div[8]/div[4]/button[2]
    Sleep    1s
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Get Text    id=next_page_url >>> xpath=/html/body/div/div[4]/div/div/p    ==    已建立

    Click With Options    id=next_page_url >>> .btn.btn-blue.fill-white.f-14-600    delay=100ms
    Fill Text    id=next_page_url >>> id=account    robot_admin2
    Fill Text    id=next_page_url >>> id=name    robot_name2
    Fill Text    id=next_page_url >>> id=tel    0987654321
    Fill Text    id=next_page_url >>> id=email    q@q.q
    Click    id=next_page_url >>> id=department
    Get Attribute    id=next_page_url >>> id=department    aria-expanded    ==    true
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[5]/div/div[1]/ul/li/a    delay=300ms    force=True
    Click    id=next_page_url >>> id=title
    Get Attribute    id=next_page_url >>> id=title    aria-expanded    ==    true
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[6]/div/div[1]/ul/li[2]/a    delay=300ms    force=True
    Select Options By    id=next_page_url >>> id=system-access    value    0
    Click    id=next_page_url >>> xpath=/html/body/div/div[6]/div[3]/button
    Fill Text    id=next_page_url >>> id=password    2
    Fill Text    id=next_page_url >>> id=passwordChcek    2
    Click    id=next_page_url >>> xpath=/html/body/div/div[8]/div[4]/button[2]
    Get Text    id=next_page_url >>> xpath=/html/body/div/div[4]/div/div/p    ==    已建立
    Sleep    1s

登入驗證權限1
    Go To    ${url}
    Wait For Elements State    id=org_number    visible
    Fill Text    id=org_number    ${org}
    Fill Text    id=account    robot_admin1
    Fill Text    id=password    1
    Click    id=loginBtn
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Hover    id=menu_aside
    Wait For Element And Click It    id=Setting_Btn

登入驗證權限2
    Go To    ${url}
    Wait For Elements State    id=org_number    visible
    Fill Text    id=org_number    ${org}
    Fill Text    id=account    robot_admin2
    Fill Text    id=password    2
    Sleep    1s
    Click    id=loginBtn
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Hover    id=menu_aside
    Wait For Elements State    id=Setting_Btn    hidden
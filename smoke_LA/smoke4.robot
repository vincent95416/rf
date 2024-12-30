*** Settings ***
Resource    ./task.robot
Suite Setup    Report Url

*** Test Cases ***
報表管理
    [Tags]    report
    [Documentation]    到報表管理建立報表做建立,編輯,刪除動作以及下載項目(歷史數據,報表)
    Wait For Elements State    css=body    visible    15s
    Click With Options    id=add_widget_div    delay=200ms
    Wait For Elements State    css=body    visible    15s
    Fill Text    id=devReport_Title_txt    robot_repo
    Click With Options    id=sava_report_btn    delay=100ms
    Wait For Elements State    css=body    visible    15s
    ${last_repo}    Get Element    xpath=/html/body/div[2]/div[2]/div[last()]/p[1]
    ${last_title}    Get Text    ${last_repo}
    Should Be Equal    ${last_title}    robot_repo
    #編輯
    Click With Options    ${last_repo}    delay=500ms    force=True
    Select Options By    id=reportDisplay    value    table_chart
    Select Options By    id=chart_list    value    ColumnChart
    Select Options By    id=search_type    value    day_report
    Click With Options    id=add-item-dropdown    delay=100ms
    Wait For Elements State    .dropdown-menu.show    visible
    Fill Text    id=Table_title    robot_col
    Click    id=dropdown_devs
    Get Attribute    id=dropdown_devs_list    class    ==    dropdown-menu menu-scroll show
    Click With Options    li[onclick="select_devs('${device1}')"]    delay=100ms
    Get Text    id=dropdown_devs_btn    ==    ${device1}
    Click    id=dropdown_nodes
    Get Attribute    id=dropdown_nodes_list    class    ==    dropdown-menu menu-scroll show
    Click With Options    li[onclick="select_nodes('co')"]    delay=100ms
    Get Text    id=dropdown_nodes_btn    ==    co
    Click    id=dropdown_statisticsType
    Get Attribute    id=dropdown_statisticsType_list    class    ==    dropdown-menu menu-scroll show
    Click With Options    li[onclick="select_statistics_type('max')"]    delay=100ms
    Get Text    id=dropdown_statisticsType_btn    ==    Maximum
    Click With Options    id=Add_select_btn    delay=100ms
    Wait For Elements State    .item-title-row.d-flex.justify-content-between    visible
    Get Text    .d-inline.item-title    ==    Item1
    Wait For Elements State    id=chart_area    visible
    Wait For Elements State    id=data_table    visible
    Get Text    xpath=/html/body/div[2]/div[1]/div[2]/div/div/div[1]/div/div[2]/p[1]/span[2]    ==    robot_col
    Click With Options    id=export_report    delay=500ms
    Wait For Elements State    .dropdown-menu.report.dropdown-menu-right.show    visible
    #在15秒內每3秒檢查下載狀態
    Sleep    1s
    ${download_1}=    Download    a[data-i18n='report.button.xls']
    Wait Until Keyword Succeeds    15s    3s    Should Be Equal    ${download_1.state}    finished
    #歷史資料下載
    Click With Options    id=sava_report_btn    delay=100ms
    Wait For Elements State    css=body    visible
    Click With Options    id=Button1    delay=100ms
    #Wait For Elements State    id=raw_iframe >>> css=body    visible
    Select Options By    id=raw_iframe >>> id=devs_list    value    ${device1}
    ${download_2}=    Download    id=raw_iframe >>> id=sava_report_btn
    Wait Until Keyword Succeeds    15s    3s    Should Be Equal    ${download_2.state}    finished
    Click With Options    id=raw_iframe >>> input[onclick="close_repair_info()"]    delay=500ms    force=True
    Wait For Elements State    id=raw_data_block    hidden
    #刪除
    ${report_id}    Get Attribute    xpath=/html/body/div[2]/div[2]/div[last()]    onclick
    Click With Options    xpath=/html/body/div[2]/div[2]/div[last()]/div/div[2]    delay=200ms
    Click    xpath=/html/body/div[2]/div[2]/div[last()]/div/div[3]/p
    Wait For Elements State    .modal.fade.show    visible
    Click With Options    id=sendEmailBtn    delay=200ms
    Check Onclick Hidden    .block-item    ${report_id}
*** Settings ***
Resource    ./task.robot
Suite Setup    Continues_page

*** Test Cases ***
報表管理
    [Documentation]    到報表管理建立報表做建立,編輯,刪除動作以及下載項目(歷史數據,報表)
    Reload
    Wait For Element And Click It    id=report_list
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Click With Options    id=next_page_url >>> id=add_widget_div
    Wait For Elements State    id=next_page_url    visible
    Fill Text    id=next_page_url >>> id=devReport_Title_txt    robot_repo
    Click With Options    id=next_page_url >>> id=sava_report_btn    delay=100ms
    Sleep    1s
    ${last_repo}    Get Element    id=next_page_url >>> xpath=/html/body/div[2]/div[2]/div[last()]/p[1]
    ${last_title}    Get Text    ${last_repo}
    Should Be Equal    ${last_title}    robot_repo
    Click With Options    ${last_repo}    delay=500ms
    Select Options By    id=next_page_url >>> id=reportDisplay    value    table_chart
    Select Options By    id=next_page_url >>> id=chart_list    value    ColumnChart
    Select Options By    id=next_page_url >>> id=search_type    value    day_report
    Sleep    1s
    Click With Options    id=next_page_url >>> id=add-item-dropdown    delay=100ms
    Wait For Elements State    id=next_page_url >>> id=search_set_area    visible
    Fill Text    id=next_page_url >>> id=Table_title    robot_col
    Click    id=next_page_url >>> id=dropdown_devs
    Get Attribute    id=next_page_url >>> id=dropdown_devs_list    class    ==    dropdown-menu menu-scroll show
    Click With Options    id=next_page_url >>> li[onclick="select_devs('${deviceID}')"]    delay=100ms
    Get Text    id=next_page_url >>> id=dropdown_devs_btn    ==    ${deviceID}
    Click    id=next_page_url >>> id=dropdown_nodes
    Get Attribute    id=next_page_url >>> id=dropdown_nodes_list    class    ==    dropdown-menu menu-scroll show
    Click With Options    id=next_page_url >>> li[onclick="select_nodes('VTP-0001')"]    delay=100ms
    Get Text    id=next_page_url >>> id=dropdown_nodes_btn    ==    VTP-0001
    Click    id=next_page_url >>> id=dropdown_statisticsType
    Get Attribute    id=next_page_url >>> id=dropdown_statisticsType_list    class    ==    dropdown-menu menu-scroll show
    Click With Options    id=next_page_url >>> li[onclick="select_statistics_type('max')"]    delay=100ms
    Get Text    id=next_page_url >>> id=dropdown_statisticsType_btn    ==    最大值
    Click With Options    id=next_page_url >>> id=Add_select_btn    delay=100ms
    Wait For Elements State    id=next_page_url >>> .item-title-row.d-flex.justify-content-between    visible
    Wait For Elements State    id=next_page_url >>> id=chart    visible
    Wait For Elements State    id=next_page_url >>> id=data_list    visible
    Click With Options    id=next_page_url >>> id=export_report    delay=500ms
    Wait For Elements State    id=next_page_url >>> .dropdown-menu.report.dropdown-menu-right.show    visible
    #在15秒內每3秒檢查下載狀態
    Sleep    1s
    ${download_1}=    Download    id=next_page_url >>> a[onclick='exportExcel()']
    Wait Until Keyword Succeeds    15s    3s    Should Be Equal    ${download_1.state}    finished
    #歷史資料下載
    Click With Options    id=next_page_url >>> id=sava_report_btn    delay=100ms
    Wait For Elements State    id=next_page_url >>> .report-list-body    visible
    Click With Options    id=next_page_url >>> p[data-i18n='report.button.history']    delay=100ms
    Wait For Elements State    id=raw_iframe    visible
    Select Options By    id=raw_iframe >>> id=devs_list    value    ${deviceID}
    ${download_2}=    Download    id=raw_iframe >>> id=sava_report_btn
    Wait Until Keyword Succeeds    15s    3s    Should Be Equal    ${download_2.state}    finished
    Click With Options    id=raw_iframe >>> input[onclick="close_repair_info()"]    delay=500ms    force=True
    Wait For Elements State    id=raw_data_block    hidden
    #刪除
    ${report_id}    Get Attribute    id=next_page_url >>> xpath=/html/body/div[2]/div[2]/div[last()]    onclick
    Click With Options    id=next_page_url >>> xpath=/html/body/div[2]/div[2]/div[last()]/div/div[2]    delay=200ms
    Sleep    1s
    ${del_button}    Get Element    id=next_page_url >>> xpath=/html/body/div[2]/div[2]/div[last()]/div/div[3]/p
    Click    ${del_button}
    Sleep    1s
    Click With Options    button[data-i18n="button.delete_confirm"]    delay=200ms
    Check Onclick Hidden    id=next_page_url >>> .block-item    ${report_id}
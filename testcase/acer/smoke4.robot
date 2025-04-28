*** Settings ***
Resource    ./task.robot
Suite Setup    Continuous page

*** Test Cases ***
報表管理
    [Tags]    report
    [Documentation]    到報表管理建立報表做建立,編輯,刪除動作以及下載項目(歷史數據,報表)
    Wait For Elements State    css=body    visible    15s
    Hover    id=menu_aside
    Wait For Element And Click It    id=report_list
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Click With Options    id=next_page_url >>> id=add_widget_div    delay=200ms
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Fill Text    id=next_page_url >>> id=devReport_Title_txt    robot_repo
    Click With Options    id=next_page_url >>> id=sava_report_btn    delay=100ms
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    ${last_repo}    Get Element    id=next_page_url >>> xpath=/html/body/div[2]/div[2]/div[last()]/p[1]
    ${last_title}    Get Text    ${last_repo}
    Should Be Equal    ${last_title}    robot_repo
    #編輯
    Click With Options    ${last_repo}    delay=500ms
    Select Options By    id=next_page_url >>> id=def_list    value    table_chart
    Select Options By    id=next_page_url >>> id=chart_list    value    ColumnChart
    Select Options By    id=next_page_url >>> id=search_type    value    day_report
    Click With Options    id=next_page_url >>> id=add-item-dropdown    delay=100ms
    Wait For Elements State    id=next_page_url >>> .dropdown-menu.show    visible
    Fill Text    id=next_page_url >>> id=Table_title    robot_col
    Click    id=next_page_url >>> id=dropdown_devs
    Get Attribute    id=next_page_url >>> id=dropdown_devs_list    class    ==    dropdown-menu menu-scroll show
    Click With Options    id=next_page_url >>> li[onclick="select_devs('${device1}')"]    delay=100ms
    Get Text    id=next_page_url >>> id=dropdown_devs_btn    ==    ${device1}
    Click    id=next_page_url >>> id=dropdown_nodes
    Get Attribute    id=next_page_url >>> id=dropdown_nodes_list    class    ==    dropdown-menu menu-scroll show
    Click With Options    id=next_page_url >>> li[onclick="select_nodes('co')"]    delay=100ms
    Get Text    id=next_page_url >>> id=dropdown_nodes_btn    ==    co
    Click    id=next_page_url >>> id=dropdown_statisticsType
    Get Attribute    id=next_page_url >>> id=dropdown_statisticsType_list    class    ==    dropdown-menu menu-scroll show
    Click With Options    id=next_page_url >>> li[onclick="select_statistics_type('max')"]    delay=100ms
    Get Text    id=next_page_url >>> id=dropdown_statisticsType_btn    ==    最大值
    Click With Options    id=next_page_url >>> id=Add_select_btn    delay=100ms
    Wait For Elements State    id=next_page_url >>> .item-title-row.d-flex.justify-content-between    visible
    Get Text    id=next_page_url >>> .d-inline.item-title    ==    項目一
    Wait For Elements State    id=next_page_url >>> id=chart_area    visible
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
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Click With Options    id=next_page_url >>> id=Button1    delay=100ms
    Wait For Elements State    id=raw_iframe >>> css=body    visible
    Select Options By    id=raw_iframe >>> id=devs_list    value    ${device1}
    ${download_2}=    Download    id=raw_iframe >>> id=sava_report_btn
    Wait Until Keyword Succeeds    15s    3s    Should Be Equal    ${download_2.state}    finished
    Click With Options    id=raw_iframe >>> input[onclick="close_repair_info()"]    delay=500ms    force=True
    Wait For Elements State    id=raw_data_block    hidden
    #刪除
    ${report_id}    Get Attribute    id=next_page_url >>> xpath=/html/body/div[2]/div[2]/div[last()]    onclick
    Click With Options    id=next_page_url >>> xpath=/html/body/div[2]/div[2]/div[last()]/div/div[2]    delay=200ms
    Click    id=next_page_url >>> xpath=/html/body/div[2]/div[2]/div[last()]/div/div[3]/p
    Wait For Elements State    .modal.fade.show    visible
    Click With Options    id=sendEmailBtn    delay=200ms
    Check Onclick Hidden    id=next_page_url >>> .block-item    ${report_id}

設備管理
    [Tags]    device
    [Documentation]    系統設定>設備管理,虛擬設備的建立編輯和刪除
    Wait For Elements State    css=body    visible
    Hover    id=menu_aside
    Wait For Element And Click It    id=Setting_Btn
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Wait For Element And Click It    id=next_page_url >>> a[href="#/devices"]
    Click With Options    id=next_page_url >>> .btn.btn-blue.fill-white.f-14-600    delay=100ms
    Get Attribute    id=next_page_url >>> id=deviceVirtualCreateOffcanvas    class    ==    offcanvas offcanvas-end show
    Fill Text    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[2]/input    devrobot
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[3]/div/div[1]/button    delay=100ms
    Get Attribute    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[3]/div/div[1]/button    class    ==    btn btn-gray dropdown-icon no-hover f-16-400 text-placeholder show
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[3]/div/div[1]/ul/li/button[1]    delay=100ms
    Get Text    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[3]/div/div[1]/ul/li[1]/button[1]    ==    B1
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[4]/div/div[1]/button    delay=100ms
    Get Attribute    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[4]/div/div[1]/button    class    ==    btn btn-gray dropdown-icon no-hover f-16-400 text-placeholder show
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[4]/div/div[1]/ul/li[1]/button[1]    delay=100ms
    Get Text    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[4]/div/div[1]/ul/li[5]/button[1]    ==    總用電
    Click With Options    id=next_page_url >>> id=addVirtualDevice    delay=100ms
    Get Attribute    id=next_page_url >>> id=select-device-Modal    class    ==    modal fade bd-example-modal-lg show
    Click    id=next_page_url >>> id=846dd41c-ecaf-4584-8e6b-13f69be09e46
    Click    id=next_page_url >>> id=e5319243-2967-4a76-bce3-0bf020f4de5b
    Wait For Elements State    id=next_page_url >>> text="加入"    enabled
    Click With Options    id=next_page_url >>> text="加入"    delay=100ms
    Wait For Elements State    id=next_page_url >>> .col-6.fw-bold.mt-4.mb-2    visible
    Should Not Contain    id=next_page_url >>> .bindNotice    至少綁定兩個設備。
    Wait For Elements State    id=next_page_url >>> xpath=/html/body/div/div[6]/div[3]/button    enabled
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[3]/button    delay=100ms
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
    Sleep    3s
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[3]/div[3]/button    delay=100ms    force=True
    Sleep    1s
    @{delete}    Get Elements    id=next_page_url >>> .btn.btn-outline-danger.border-0.f-14-600
    Click With Options    ${delete}[0]    delay=500ms
    Sleep    1s
    Get Attribute    id=next_page_url >>> id=checkDeleteModal    class    ==    modal fade show
    Get Text    id=next_page_url >>> xpath=/html/body/div[1]/div[9]/div/div/div[2]/p/span    ==    devicerobot
    Click With Options    id=next_page_url >>> .f-14-600.btn.btn-delete.btn-172-44    delay=100ms
    Wait For Elements State    id=next_page_url >>> css=td:has-text("devicerobot")    detached    5s

新增,刪除管理者帳號
    [Tags]    account
    Wait For Elements State    css=body    visible
    Hover    id=menu_aside
    Wait For Element And Click It    id=Setting_Btn
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Click With Options    id=next_page_url >>> .btn.btn-blue.fill-white.f-14-600    delay=100ms
    Fill Text    id=next_page_url >>> id=account    robot_admin1
    Fill Text    id=next_page_url >>> id=name    robot_name1
    Fill Text    id=next_page_url >>> id=tel    0987654321
    Fill Text    id=next_page_url >>> id=email    q@q.q
    Click    id=next_page_url >>> id=department
    Get Attribute    id=next_page_url >>> id=department    aria-expanded    ==    true
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[5]/div/div[1]/ul/li[1]/a    delay=300ms    force=True
    Click    id=next_page_url >>> id=title
    Get Attribute    id=next_page_url >>> id=title    aria-expanded    ==    true
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[6]/div/div[1]/ul/li[1]/a    delay=300ms    force=True
    Select Options By    id=next_page_url >>> id=system-access    value    0
    Click    id=next_page_url >>> text="下一步"
    Sleep    1s
    Fill Text    id=next_page_url >>> id=password    0
    Fill Text    id=next_page_url >>> id=passwordChcek    0
    Click    id=next_page_url >>> xpath=/html/body/div/div[8]/div[4]/button[2]
    Wait For Elements State    id=next_page_url >>> .table.table-hover    stable
    Wait For Elements State    id=next_page_url >>> css=td:has-text("robot_name1")    detached    5s
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[2]/section[2]/div[2]/div/table/tbody[last()]/tr/td[10]/div/button[2]    delay=300ms
    Wait For Elements State    id=next_page_url >>> .modal-open    visible
    Sleep    1s
    Click With Options    id=next_page_url >>> xpath=/html/body/div[1]/div[3]/div/div/div[2]/div/button[1]    delay=300ms    clickCount=2
    Wait For Elements State    id=next_page_url >>> text="robot_name1"    hidden
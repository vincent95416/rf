*** Settings ***
Resource    ./task.robot
Suite Setup    TTest Browser

*** Keywords ***
TTest Browser
    New Browser    chromium    headless=False    slowMo=1
    New Context    viewport={'width': 1600, 'height': 900}    acceptDownloads=True
    New Page    ${url}    load
    Log    Testing version ${VERSION} in ${ENV} environment

*** Test Cases ***
登入
    [Tags]    high_priority
    [Documentation]    輸入組織ID,帳號密碼並登入
    Fill Text    id=account    ${acc}
    Fill Text    id=password    ${pw}
    Click    id=loginBtn
    Wait For Load State    load    30
    Wait For Elements State    css=body    visible    15s
    Wait For Elements State    .wrapper    visible    20s
    ${current_url}=    Get Url
    Set Global Variable    ${main_url}    ${current_url}

widget編輯模式
    [Documentation]    打開widget編輯模式,以利後續測試
    Wait For Load State    load    30s
    Wait For Elements State    css=body    visible
    Wait For Element And Click It    id=next_page_url >>> id=btn_show_widget
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s

新增頁面
    [Tags]    page
    Wait For Elements State    .wrapper    visible    15s
    Hover    id=menu_aside
    Wait For Element And Click It    id=addmenu
    Wait For Elements State    id=iframe_device >>> css=body    visible    15s
    Click   id=iframe_device >>> id=menu_txt
    Fill Text    id=iframe_device >>> input[id=menu_txt]    robot
    Click With Options   id=iframe_device >>> id=nav_ic_ac_div    force=True
    ${border_color}=    Get Style    id=iframe_device >>> id=nav_ic_ac_div    border-color
    Should Be Equal    ${border_color}    rgb(33, 77, 124)
    Click   id=iframe_device >>> id=go_toSet_page_btn
    Wait For Elements State    id=iframe_device >>> id=page_txt    visible    15s
    Fill Text    id=iframe_device >>> id=page_txt    robot1
    Sleep    1s
    Click   id=iframe_device >>> id=page_edit_submit
    sleep    1s

刪除頁面
    [Tags]    page
    Wait For Elements State    .wrapper    visible    15s
    Hover    id=menu_aside
    Wait For Element And Click It    id=Setting_Btn
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Hover    css=body
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[2]/ul/li[2]    delay=100ms
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Wait For Elements State    id=next_page_url >>> .table.table-hover    stable
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[2]/section[2]/div[2]/div/table/tbody/tr[last()]/td[4]/div/button[2]    delay=500ms
    Wait For Elements State    id=next_page_url >>> .modal.fade.show    visible
    Click With Options    id=next_page_url >>> xpath=/html/body/div[1]/div[4]/div/div/div[2]/div/button[1]
    Wait For Elements State    .wrapper    visible    15s
    ${page}    Get Text    id=next_page_url >>> xpath=/html/body/div/div[2]/section[2]/div[2]/div/table/tbody/tr[last()]/td[1]/div/p
    Should Not Be Equal    ${page}    robot

新增平面圖
    [Tags]    map
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Hover    id=menu_aside
    Wait For Element And Click It    //p[@class="nav_page_text" and text()="測試"]
    Click With Options    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='${init_label}']    clickCount=2
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=平面圖_btn
    #Click With Options    id=XL_cardType_widgets    force=True
    #現在onclick事件有bug,無法選中XL的平面圖widget,因此改執行下兩行程式碼
    Click With Options    xpath=/html/body/div[3]/div[2]/div[1]/div/div/div[1]/p[2]    delay=200ms
    Get Attribute    id=Map_L_div    class    ==    widget-group widget-donut widget-selected
    Sleep    2s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    大平面圖
    Fill Text    id=s_title    小平面圖
    Click With Options    .btn-clear.d-flex.flex-row.align-items-center.f-16-600.c-blue.mt-2.mb-3    delay=200ms
    Wait For Elements State    id=iframe_map >>> css=body    visible    15s
    Upload File By Selector    id=iframe_map >>> input#file2    53W8K9.jpg
    Click With Options    id=iframe_map >>> id=upload_submit    delay=200ms
    Get Text    id=status_msg_content    ==    已上傳
    Get Attribute    id=iframe_map >>> id=nomap_icon    class    ==    icon icon-100 icon-nomap d-none
    Get Text    id=iframe_map >>> id=map_name_show    ==    53W8K9.jpg
    #icon新增
    Wait For Element And Click It    id=iframe_map >>> id=add_widget_btn
    Wait For Elements State    id=iframe_map >>> id=iframe_map_widget >>> css=body    visible    15s
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=device_model_select    value    6
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=next_widget_btn    delay=300ms
    Get Attribute    id=iframe_map >>> id=iframe_map_widget >>> id=step2_title    class    ==    path active
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=data_node_dev    value    ${device1}
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=add_btn    delay=200ms
    Sleep    1s
    ${icon1}    Get Element    id=iframe_map >>> css=span[databind='${device1}NODEco']
    Hover    ${icon1}
    Wait For Elements State    id=iframe_map >>> .map_widget_hover    visible
    ${nowrap1}    Get text    id=iframe_map >>> xpath=/html/body/div[2]/div[2]/div/div[2]/div[2]/div[2]
    Should Contain    ${nowrap1}    室內空氣品質：
    Sleep    1s
    Click With Options    id=iframe_map >>> id=Save_Btn    delay=200ms
    Click With Options    id=old_save_Btn    delay=200ms
    Sleep    3s

編輯平面圖
    [Tags]    map
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Click With Options    id=next_page_url >>> css=button.icon.icon-three-dots.icon-40[onclick='widgetEdit(event)']    delay=200ms
    Click    id=next_page_url >>> css=span[data-i18n='widget.edit.map']
    Wait For Elements State    id=iframe_map >>> css=body    visible    15s
    Upload File By Selector    id=iframe_map >>> input#file2    90909.jpg
    Sleep    1s
    Click With Options    id=iframe_map >>> id=upload_submit    delay=200ms
    Sleep    1s
    Wait For Elements State    id=iframe_map >>> id=map_name_show    stable
    Get Text    id=iframe_map >>> id=map_name_show    ==    90909.jpg
    #icon處理,刪除、編輯等動作
    Click With Options    id=iframe_map >>> .widget-box    delay=500ms    button=right
    Wait For Elements State    id=iframe_map >>> id=menu    visible
    Click With Options    id=iframe_map >>> id=Edit_btn    delay=200ms
    Wait For Elements State    id=iframe_map >>> id=iframe_map_widget >>> id=widget_demo_view_area    visible
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=next_widget_btn    delay=300ms
    Fill Text    id=iframe_map >>> id=iframe_map_widget >>> id=unit    Q
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=add_btn    delay=100ms
    Get Text    id=iframe_map >>> xpath=/html/body/div[2]/div[2]/div/div[2]/div/span[2]    ==    Q
    Click With Options    id=iframe_map >>> .widget-box    delay=500ms    button=right
    Wait For Elements State    id=iframe_map >>> id=menu    visible
    Click With Options    id=iframe_map >>> id=Del_btn   delay=200ms
    Wait For Elements State    id=iframe_map >>> .widget-box    detached
    #新增不同種類icon，後續複製
    Wait For Element And Click It    id=iframe_map >>> id=add_widget_btn
    Wait For Elements State    id=iframe_map >>> id=iframe_map_widget >>> css=body    visible    15s
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=device_model_select    value    3
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=widget_icon_select    label    Ao
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=next_widget_btn    delay=300ms
    Get Attribute    id=iframe_map >>> id=iframe_map_widget >>> id=step2_title    class    ==    path active
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=data_node_dev    value    ${device2}
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=add_btn    delay=200ms
    Sleep    1s
    ${icon2}    Get Element    id=iframe_map >>> css=span[databind='${device2}NODEKWHDay']
    Hover    ${icon2}
    Wait For Elements State    id=iframe_map >>> .map_widget_hover    visible
    ${nowrap3}    Get text    id=iframe_map >>> xpath=/html/body/div[2]/div[2]/div/div[2]/div[2]/div[5]
    Should Contain    ${nowrap3}    風速：
    Sleep    1s
    Click With Options    ${icon2}    delay=500ms    button=right
    Wait For Elements State    id=iframe_map >>> .menu    visible
    Click With Options    id=iframe_map >>> id=Copy_btn
    @{box}    Get Elements    id=iframe_map >>> .widget-box
    Length Should Be    ${box}    2
    Get Widget ID    id=iframe_map    src
    Click With Options    id=iframe_map >>> id=Save_Btn    delay=200ms
    Sleep    1s
    @{map_icon}    Get Elements    id=next_page_url >>> id=${WIDGET_ID}_MAP >>> .dragItem.widget-map.ao.show.offline
    Length Should Be    ${map_icon}    2
    ${outside_nowrap3}    Get Text    id=next_page_url >>> id=${WIDGET_ID}_MAP >>> xpath=/html/body/div[2]/div[2]/div/div[2]/div[2]/div[3]/span[2]
    Should Contain    ${outside_nowrap3}    ${nowrap3}

刪除平面圖
    [Tags]    map
    Click With Options    id=next_page_url >>> css=button.icon.icon-three-dots.icon-40[onclick='widgetEdit(event)']    delay=200ms
    Wait For Elements State    id=next_page_url >>> .widget-menu.list-group.d-block    visible
    Click With Options    id=next_page_url >>> .delete    delay=200ms    force=True
    Wait For Elements State    id=next_page_url >>> .modal.fade.show    visible
    Click With Options    id=next_page_url >>> id=delete_submit    delay=200ms
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Wait For Elements State    id=next_page_url >>> id=${WIDGET_ID}_MAP    detached

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

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

建立管理者，後續驗證並刪除
    Hover    id=menu_aside
    Wait For Element And Click It    id=Setting_Btn
    Wait For Elements State    id=next_page_url >>> .account-container    visible
    Click With Options    id=next_page_url >>> .btn.btn-blue.fill-white.f-14-600    delay=100ms
    Fill Text    id=next_page_url >>> id=account    robot_g
    Fill Text    id=next_page_url >>> id=name    gholdengo
    Fill Text    id=next_page_url >>> id=tel    0916738245
    Fill Text    id=next_page_url >>> id=email    c@c.c
    Click    id=next_page_url >>> id=department
    Get Attribute    id=next_page_url >>> id=department    aria-expanded    ==    true
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[5]/div/div[1]/ul/li/a    delay=300ms    force=True
    Click    id=next_page_url >>> id=title
    Get Attribute    id=next_page_url >>> id=title    aria-expanded    ==    true
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[6]/div/div[1]/ul/li[2]/a    delay=300ms    force=True
    Select Options By    id=next_page_url >>> id=system-access    value    0
    Select Options By    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[8]/div/div[1]/select    label    QA
    Click With Options    id=next_page_url >>> id=dropdown-access-0    delay=100ms
    Wait For Elements State    id=next_page_url >>> .dropdown-menu.overflow-hidden.w-188.show    visible
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[6]/div[2]/form/div/div[8]/div/div[2]/ul/li[2]/a    delay=100ms
    Click    id=next_page_url >>> xpath=/html/body/div/div[6]/div[3]/button
    Sleep    1s
    Fill Text    id=next_page_url >>> id=password    1
    Fill Text    id=next_page_url >>> id=passwordChcek    1
    Click    id=next_page_url >>> xpath=/html/body/div/div[8]/div[4]/button[2]
    Sleep    1s
    Get Text    id=next_page_url >>> xpath=/html/body/div/div[4]/div/div/p    ==    已建立
    Sleep    5s
    ${access}    Get Text    id=next_page_url >>> xpath=//table/tbody[last()]/tr/td[8]
    Should Be Equal    ${access}    否
    
    ${spans}=    Get Elements    id=next_page_url >>> xpath=//table/tbody[last()]/tr/td[9]/span
    ${span_count}=    Get Length    ${spans}
    Should Be Equal As Numbers    ${span_count}    1
    ${span_text}    Get Text    ${spans}[0]
    Should Be Equal    ${span_text}    QA

    Click With Options    id=next_page_url >>> xpath=//table/tbody[last()]/tr/td[10]/div/button[2]    delay=500ms
    Wait For Elements State    id=next_page_url >>> .modal fade show    visible
    ${text}    Get Text    /html/body/div[1]/div[3]/div/div/div[2]/p/span
    Should Contain    ${text}    robot_g
    Click With Options    id=next_page_url >>> xpath=/html/body/div[1]/div[3]/div/div/div[2]/div/button[1]    delay=500ms
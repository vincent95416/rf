*** Settings ***
Resource    ./task.robot
Suite Setup    Initialize Browser

*** Test Cases ***
login/authorization
    [Documentation]    登入後取得url,token，(待後續整合到每分案例的setup)
    New Page    ${url}    load
    Fill Text    id=account    ${acc}
    Fill Text    id=password    ${pw}
    Click    id=loginBtn
    Wait For Load State    load    30
    Wait For Elements State    .wrapper    visible    15s
    ${current_url}=    Get Url
    ${key_token}    Session Storage Get Item    token
    Log    ${key_token}
    Set Global Variable    ${main_url}    ${current_url}
    Set Global Variable    ${token}    ${key_token}
*** Settings ***
Resource    ../task.robot
Suite Setup    Basic Browser

*** Test Cases ***
登入
    [Documentation]    登入後取得url,token，(待後續整合到每分案例的setup)
    New Page    ${url}    load
    Fill Text    id=account    ${acc}
    Fill Text    id=password    ${pw}
    Click    id=loginBtn
    Wait For Load State    load    30
    Wait For Elements State    .wrapper    visible    15s
    ${current_url}=    Get Url
    ${token_start}    Get Regexp Matches    ${current_url}    token=([a-zA-Z0-9]+)    1
    ${extracted_token}    Set Variable    ${token_start}[0]
    Log    ${extracted_token}
    Set Global Variable    ${main_url}    ${current_url}
    Set Global Variable    ${token}    ${extracted_token}

#api檢測
#    [Documentation]    帳號操作、
#    #新增帳號、刪除帳號
#    &{headers}    Create Dictionary    Content-Type=application/json    Authorization=${token}
#    ${newuser_response}    POST    url=http://192.168.11.26/api/User/addNewUser    headers=&{headers}    json=&{newuser_payload}    expected_status=200
#    ${newuser_data}    Set Variable    ${newuser_response.json()}[data]
#    Log    ${newuser_data}
#    ${user_id}    Set Variable    ${newuser_uid}[uid]
#    ${delete_response}    DELETE    url=http://192.168.11.26/api/OrgAccount/DelOrgAccount?gid=00000000-0000-0000-0000-000000000000&uid=${user_id}    headers=&{headers}    expected_status=200
#    Assert Result 0    ${delete_response}
#    #帳號列表
#    ${userlist_response}    GET    url=http://192.168.11.26/api/User/listinfo/00000000-0000-0000-0000-000000000000    headers=&{headers}    expected_status=200
#    Assert Result 0    ${userlist_response}
#    #設備列表
#    ${devlist_response}    GET    url=http://192.168.11.26/api/Device/list?groupId=00000000-0000-0000-0000-000000000000    headers=&{headers}    expected_status=200
#    Assert Result 0    ${userlist_response}
# coding: utf-8

User.create!(name:  "上長A",
             email: "superior-a@example.com",
             password:              "password",
             #password_confirmation: "password",
             admin: false,
             affiliation: "システム部A",
             basic_work_time: "2019-11-19 08:00:00",
             designated_work_start_time: "2019-11-19 09:00:00",
             designated_work_end_time: "2019-11-19 18:00:00",
             superior: true,
             employer_number: 1001,
             uid: "xy98n001")

User.create!(name:  "上長B",
             email: "superior-b@example.com",
             password:              "password",
             #password_confirmation: "password",
             admin: false,
             affiliation: "システム部B",
             basic_work_time: "2019-11-19 08:00:00",
             designated_work_start_time: "2019-11-19 09:00:00",
             designated_work_end_time: "2019-11-19 18:00:00",
             superior: true,
             employer_number: 1002,
             uid: "xy98n002")

User.create!(name:  "上長C",
             email: "superior-c@example.com",
             password:              "password",
             #password_confirmation: "password",
             admin: false,
             affiliation: "システム部C",
             basic_work_time: "2019-11-19 08:00:00",
             designated_work_start_time: "2019-11-19 09:00:00",
             designated_work_end_time: "2019-11-19 18:00:00",
             superior: true,
             employer_number: 1003,
             uid: "xy98n003")

User.create!(name:  "一般ユーザーA",
             email: "ippan-a@example.com",
             password:              "password",
             #password_confirmation: "password",
             admin: false,
             affiliation: "システム部A",
             basic_work_time: "2019-11-19 08:00:00",
             designated_work_start_time: "2019-11-19 09:00:00",
             designated_work_end_time: "2019-11-19 18:00:00",
             superior: false,
             employer_number: 2001,
             uid: "xy99n001")

User.create!(name:  "一般ユーザーB",
             email: "ippan-b@example.com",
             password:              "password",
             #password_confirmation: "password",
             admin: false,
             affiliation: "システム部B",
             basic_work_time: "2019-11-19 08:00:00",
             designated_work_start_time: "2019-11-19 09:00:00",
             designated_work_end_time: "2019-11-19 18:00:00",
             superior: false,
             employer_number: 2002,
             uid: "xy99n002")

User.create!(name:  "一般ユーザーC",
             email: "ippan-c@example.com",
             password:              "password",
             #password_confirmation: "password",
             admin: false,
             affiliation: "システム部C",
             basic_work_time: "2019-11-19 08:00:00",
             designated_work_start_time: "2019-11-19 09:00:00",
             designated_work_end_time: "2019-11-19 18:00:00",
             superior: false,
             employer_number: 2003,
             uid: "xy99n003")

User.create!(name:  "管理者A",
             email: "kanri-a@example.com",
             password:              "password",
             #password_confirmation: "password",
             admin: true,
             affiliation: "管理本部A",
             basic_work_time: "2019-11-19 08:00:00",
             designated_work_start_time: "2019-11-19 09:00:00",
             designated_work_end_time: "2019-11-19 18:00:00",
             superior: false,
             employer_number: 3001,
             uid: "xy00n001")

User.create!(name:  "管理者B",
             email: "kanri-b@example.com",
             password:              "password",
             #password_confirmation: "password",
             admin: true,
             affiliation: "管理本部B",
             basic_work_time: "2019-11-19 08:00:00",
             designated_work_start_time: "2019-11-19 09:00:00",
             designated_work_end_time: "2019-11-19 18:00:00",
             superior: false,
             employer_number: 3002,
             uid: "xy00n002")

User.create!(name:  "管理者C",
             email: "kanri-c@example.com",
             password:              "password",
             #password_confirmation: "password",
             admin: true,
             affiliation: "管理本部C",
             basic_work_time: "2019-11-19 08:00:00",
             designated_work_start_time: "2019-11-19 09:00:00",
             designated_work_end_time: "2019-11-19 18:00:00",
             superior: false,
             employer_number: 3003,
             uid: "xy00n003")

#59.times do |n|
  #name  = Faker::Name.name
#  name  = Gimei.name.kanji
#  email = "email#{n+1}@sample.com"
#  password = "password"
#  User.create!(name:  name,
#               email: email,
#               password:              password,
#               password_confirmation: password)
#end

#Approval.create!(user_id: 1,
#                 kintai_req_on: "2019-07-01",
#                 approval_status: "申請中",
#                 target_person_id: 4)

#Approval.create!(user_id: 1,
#                 kintai_req_on: "2019-06-01",
#                 approval_status: "承認",
#                 target_person_id: 4)
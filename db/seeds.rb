# coding: utf-8

User.create!(name:  "上長A",
             email: "jyocho-a@sample.com",
             password:              "password",
             #password_confirmation: "password",
             admin: false,
             department: "システム部A",
             basic_time: "2019-07-01 22:30:00",
             work_time: "2019-07-02 00:00:00",
             work_end_time: "2019-07-02 09:00:00",
             senior: true,
             employer_number: 1001,
             uid: "xy98n001")

User.create!(name:  "上長B",
             email: "jyocho-b@sample.com",
             password:              "password",
             #password_confirmation: "password",
             admin: false,
             department: "システム部B",
             basic_time: "2019-07-01 22:30:00",
             work_time: "2019-07-02 00:00:00",
             work_end_time: "2019-07-02 09:00:00",
             senior: true,
             employer_number: 1002,
             uid: "xy98n002")

User.create!(name:  "上長C",
             email: "jyocho-c@sample.com",
             password:              "password",
             #password_confirmation: "password",
             admin: false,
             department: "システム部C",
             basic_time: "2019-07-01 22:30:00",
             work_time: "2019-07-02 00:00:00",
             work_end_time: "2019-07-02 09:00:00",
             senior: true,
             employer_number: 1003,
             uid: "xy98n003")

User.create!(name:  "一般ユーザーA",
             email: "ippan-a@sample.com",
             password:              "password",
             #password_confirmation: "password",
             admin: false,
             department: "システム部A",
             basic_time: "2019-07-01 22:30:00",
             work_time: "2019-07-02 00:00:00",
             work_end_time: "2019-07-02 09:00:00",
             senior: false,
             employer_number: 2001,
             uid: "xy99n001")

User.create!(name:  "一般ユーザーB",
             email: "ippan-b@sample.com",
             password:              "password",
             #password_confirmation: "password",
             admin: false,
             department: "システム部B",
             basic_time: "2019-07-01 22:30:00",
             work_time: "2019-07-02 00:00:00",
             work_end_time: "2019-07-02 09:00:00",
             senior: false,
             employer_number: 2002,
             uid: "xy99n002")

User.create!(name:  "一般ユーザーC",
             email: "ippan-c@sample.com",
             password:              "password",
             #password_confirmation: "password",
             admin: false,
             department: "システム部C",
             basic_time: "2019-07-01 22:30:00",
             work_time: "2019-07-02 00:00:00",
             work_end_time: "2019-07-02 09:00:00",
             senior: false,
             employer_number: 2003,
             uid: "xy99n003")

User.create!(name:  "管理者A",
             email: "kanri-a@sample.com",
             password:              "password",
             #password_confirmation: "password",
             admin: true,
             department: "管理本部A",
             basic_time: "2019-07-01 22:30:00",
             work_time: "2019-07-02 00:00:00",
             work_end_time: "2019-07-02 09:00:00",
             senior: false,
             employer_number: 3001,
             uid: "xy00n001")

User.create!(name:  "管理者B",
             email: "kanri-b@sample.com",
             password:              "password",
             #password_confirmation: "password",
             admin: true,
             department: "管理本部B",
             basic_time: "2019-07-01 22:30:00",
             work_time: "2019-07-02 00:00:00",
             work_end_time: "2019-07-02 09:00:00",
             senior: false,
             employer_number: 3002,
             uid: "xy00n002")

User.create!(name:  "管理者C",
             email: "kanri-c@sample.com",
             password:              "password",
             #password_confirmation: "password",
             admin: true,
             department: "管理本部C",
             basic_time: "2019-07-01 22:30:00",
             work_time: "2019-07-02 00:00:00",
             work_end_time: "2019-07-02 09:00:00",
             senior: false,
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

Approval.create!(user_id: 1,
                 kintai_req_on: "2019-07-01",
                 approval_status: "申請中",
                 target_person_id: 4)

Approval.create!(user_id: 1,
                 kintai_req_on: "2019-06-01",
                 approval_status: "承認",
                 target_person_id: 4)
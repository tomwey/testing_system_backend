module API
  module V1
    module Entities
      class Base < Grape::Entity
        format_with(:null) { |v| v.blank? ? "" : v }
        format_with(:chinese_date) { |v| v.blank? ? "" : v.strftime('%Y-%m-%d') }
        format_with(:chinese_datetime) { |v| v.blank? ? "" : v.strftime('%Y-%m-%d %H:%M:%S') }
        format_with(:month_date_time) { |v| v.blank? ? "" : v.strftime('%m月%d日 %H:%M') }
        format_with(:money_format) { |v| v.blank? ? '0.00' : ('%.2f' % v) }
        format_with(:rmb_format) { |v| v.blank? ? '0.00' : ('%.2f' % (v / 100.00)) }
        expose :id
        expose :created_at, as: :create_time, format_with: :chinese_datetime
        # expose :created_at, format_with: :chinese_datetime
      end # end Base
      
      class UserBase < Base
        expose :uid, as: :id
        expose :private_token, as: :token
        expose :is_authed do |model, opts|
          model.idcard.present?
        end
      end
      
      # 用户基本信息
      # class UserProfile < UserBase
      #   # expose :uid, format_with: :null
      #   expose :mobile, format_with: :null
      #   expose :nickname do |model, opts|
      #     model.format_nickname
      #   end
      #   expose :avatar do |model, opts|
      #     model.real_avatar_url
      #   end
      #   expose :nb_code, as: :invite_code
      #   expose :earn, format_with: :money_format
      #   expose :balance, format_with: :money_format
      #   expose :today_earn, format_with: :money_format
      #   expose :wx_id, format_with: :null
      #   unexpose :private_token, as: :token
      # end
      
      class AppVersion < Base
        expose :version
        expose :os
        expose :change_log, as: :changelog
        # expose :changelog do |model, opts|
        #   if model.change_log
        #     arr = model.change_log.split('</p><p>')
        #     arr.map { |s| s.gsub('</p>', '').gsub('<p>', '') }
        #   else
        #     []
        #   end
        # end
        expose :app_url
        expose :must_upgrade
      end
      
      class QuestionType < Base
        expose :name, :memo
      end
      
      class ExamPoint < Base
        expose :name, :summary, :memo
      end
      
      # 用户资料
      class UserProfile < UserBase
        unexpose :private_token, as: :token
        expose :name, :idcard, :mobile
        expose :format_nickname, as: :nickname
        # expose :total_salary_money, as: :total_money, format_with: :money_format
        # expose :sent_salary_money, as: :payed_money, format_with: :money_format
        # expose :senting_salary_money, as: :unpayed_money, format_with: :money_format
      end
      # 用户详情
      class User < UserBase
        expose :uid, as: :id
        expose :mobile, format_with: :null
        expose :nickname do |model, opts|
          model.format_nickname
        end
        expose :avatar do |model, opts|
          model.format_avatar_url
        end
        expose :balance, format_with: :rmb_format
        expose :vip_expired_at, as: :vip_time, format_with: :chinese_date
        expose :left_days, as: :vip_status
        expose :qrcode_url
        expose :portal_url
        unexpose :private_token, as: :token
        expose :wx_bind
        expose :qq_bind
        
        # expose :vip_expired_at, as: :vip_time, format_with: :chinese_date
        # expose :left_days do |model, opts|
        #   model.left_days
        # end
        # expose :private_token, as: :token, format_with: :null
      end
      
      class SimpleUser < Base
        expose :uid, as: :id
        expose :mobile, format_with: :null
        expose :nickname do |model, opts|
          model.format_nickname
        end
        expose :avatar do |model, opts|
          model.format_avatar_url
        end
      end
      
      class SimplePage < Base
        expose :title, :slug
      end
      
      class Page < SimplePage
        expose :title, :body
      end
      
      class SimpleCompany < Base
        expose :brand
        # expose :logo do |model, opts|
        #   model.logo.blank? ? '' : model.logo.url(:big)
        # end
        expose :logo_url
        expose :logo_url, as: :logo
        expose :logo_url, as: :logo_id
        expose :theme do |model, opts|
          '#' + "#{model.id}"
        end
        expose :slogan do |model, opts|
          "让创造更容易"
        end
        expose :services do |model, opts|
          "码小易，青少年创客教育服务商"
        end
      end
      
      class SimpleAccount < Base
        expose :mobile, format_with: :null
        expose :name, format_with: :null
        expose :avatar do |model, opts|
          model.avatar.blank? ? '' : model.avatar.url(:big)
        end
        expose :private_token, as: :token
      end
      
      class Company < SimpleCompany
        expose :balance, format_with: :rmb_format
        expose :_balance, :name, :mobile, :address, :opened
        expose :vip_time, format_with: :chinese_date do |model,opts|
          model.parent ? model.parent.vip_expired_at : model.vip_expired_at
        end
        expose :left_days do |model,opts|
          model.parent ? model.parent.left_days : model.left_days
        end
        expose :license_no, :license_image_url
        expose :license_image_url, as: :license_image_id
        expose :admin, using: API::V1::Entities::SimpleAccount do |model,opts|
          model.accounts.where(is_admin: true).first
        end
      end
      
      class SimpleCategory < Base
        expose :name, :memo, :opened
      end
      
      class Category < SimpleCategory
        expose :name, :memo, :opened
        expose :courses_count do |model, opts|
          model.courses.size
        end
      end
      
      class Certificate < Base
        expose :title, :cover, :cover_url, :memo, :status
        expose :category, using: API::V1::Entities::SimpleCategory
      end
      
      class SimpleTag < Base
        expose :name, :memo, :opened
      end
      
      class Tag < SimpleTag
        expose :name, :memo, :opened
        expose :articles_count do |model, opts|
          model.articles.size
        end
      end
      
      class SimpleRole < Base
        expose :name
      end
      
      class Account < SimpleAccount
        expose :is_admin, :opened, :role_ids
        expose :last_login_at, format_with: :chinese_datetime
        expose :last_login_ip
        expose :login_count
        # expose :company, using: API::V1::Entities::Company
        unexpose :private_token, as: :token
        expose :token_md5 do |model,opts|
          Digest::MD5.hexdigest(model.private_token)
        end
        expose :roles, using: API::V1::Entities::SimpleRole
        expose :func_actions, as: :permissions
      end
      
      class AttendGrade < Base
        expose :name, :memo, :sort
      end
      
      class AttendSchool < Base
        expose :name, :contact_name, :contact_phone, :address, :memo, :bio
        expose :opened, :sort
        expose :attend_grades, as: :grades, using: API::V1::Entities::AttendGrade
        expose :students_count
      end
      
      class Teacher < Base
        expose :name, :nickname, :avatar, :avatar_url, :age, :country, :mobile, :mobile2, :_type
        expose :type_name, :bio, :memo, :opened, :login_count, :last_login_at, :last_login_ip
        expose :approved_at, as: :approve_time, format_with: :chinese_datetime
        expose :wechat, :qq, :wechat_qrcode, :wechat_qrcode_url
      end
      
      class AssocAccount < Base
        expose :mobile, format_with: :null
        expose :name, format_with: :null
        expose :roles, using: API::V1::Entities::SimpleRole
      end
      
      class School < Base
        expose :name, :contact_name, :contact_phone, :address, :memo, :bio
        expose :is_co_school
        expose :students_count, :opened
        expose :assoc_accounts, using: API::V1::Entities::AssocAccount
      end
      
      class Classroom < Base
        expose :name, :memo, :opened
        expose :school_id
        expose :school_name do |model,opts|
          model.school.try(:name)
        end
      end
      
      class SimpleSysClass < Base
        expose :name, :memo, :students_count, :found_on
      end
      
      class Parent < Base
        expose :name, :memo, :login_count, :last_login_ip, :last_login_at, :opened
        expose :mobile
        expose :avatar do |model,opts|
          model.avatar.blank? ? '' : model.avatar.url(:big)
        end
      end
      
      class SimpleStudent < Base
        expose :name, :memo, :age, :gender, :grade_id, :attend_school_id, :address, :school_id
        expose :mobile, :avatar
        expose :format_avatar, as: :avatar_url
        expose :attend_grade, as: :grade, using: API::V1::Entities::AttendGrade
        expose :attend_school, as: :from_school, using: API::V1::Entities::AttendSchool
      end
      
      class Student < Base
        expose :name, :memo, :age, :gender, :grade_id, :attend_school_id, :address, :school_id
        expose :mobile, :avatar
        expose :format_avatar, as: :avatar_url
        expose :school_name do |model, opts|
          model.school.try(:name)
        end
        expose :parents, using: API::V1::Entities::Parent
        expose :class_ids
        expose :sys_classes, as: :classes, using: API::V1::Entities::SimpleSysClass
        expose :attend_grade, as: :grade, using: API::V1::Entities::AttendGrade
        expose :attend_school, as: :from_school, using: API::V1::Entities::AttendSchool
      end
      
      class Attachment < Base
        expose :content_type do |model, opts|
          model.data.content_type
        end
        expose :url do |model, opts|
          model.data.url
        end
        expose :filename do |model,opts|
          model.old_filename || model.data_file_name
        end
        expose :filesize do |model,opts|
          model.data_file_size
        end
        expose :width, :height
      end
      
      class CourseUnitContent < Base
        expose :name, :_type, :download_count, :file, :memo, :sort, :file_url
        expose :file_size
        expose :type_name
        expose :course_unit_id
      end
      
      class Content < Base
        expose :name, :_type, :view_count, :download_count, :file, :memo
        expose :size, :body
        expose :type_name
        expose :cover, :cover_url
        expose :assets, using: API::V1::Entities::Attachment
      end
      
      class Video < Base
        expose :name, :play_count, :download_count, :file, :memo, :filename, :opened
        expose :duration, :body
        # expose :type_name
        expose :cover, :cover_url
        # expose :assets, using: API::V1::Entities::Attachment, if: proc { |o| o._type != 4 }
        expose :mp4_url
        expose :encrypted
      end
      
      class UnitVideo < Base
        expose :video, using: API::V1::Entities::Video
        expose :sort
      end
      
      class UnitContent < Base
        expose :content, using: API::V1::Entities::Content
        expose :sort
      end
      
      class SimpleExam < Base
        expose :name, :bio, :sort, :memo, :opened, :_type, :pid, :type_name
      end
      
      class ExamOwner < Base
        expose :exam, using: API::V1::Entities::SimpleExam
        expose :sort
      end
      
      class SimpleCourseUnit < Base
        expose :name, :pid, :sort
      end
      
      class CourseUnit < SimpleCourseUnit
        expose :intro, :teach_length, :memo, :opened, :cover
        expose :cover_url
        # expose :contents, using: API::V1::Entities::Content
        # expose :unit_videos, as: :videos, using: API::V1::Entities::UnitVideo
        # expose :unit_contents, as: :assignments, using: API::V1::Entities::UnitContent do |model,opts|
        #   model.unit_contents.joins(:content).where(contents: {_type: 2})
        # end
        # expose :unit_contents, as: :ppts, using: API::V1::Entities::UnitContent do |model,opts|
        #   model.unit_contents.joins(:content).where(contents: {_type: 1})
        # end
        # expose :exam_owners, as: :exams, using: API::V1::Entities::ExamOwner
        expose :parent, using: API::V1::Entities::SimpleCourseUnit
        expose :child_count, :exam_ids
      end
      
      class Course < Base
        expose :name, :cover, :intro, :body, :price, :teach_mode, :sort, :opened, :m_price, :units_count
        expose :cover_url, :live_url
        expose :categories, using: API::V1::Entities::SimpleCategory
        # expose :category_ids
        expose :teach_mode_name
        expose :course_units, as: :units, using: API::V1::Entities::CourseUnit
        expose :main_teacher, using: API::V1::Entities::Teacher
        expose :assist_teacher, using: API::V1::Entities::Teacher
        expose :exam_ids, :main_teacher_id, :assist_teacher_id
      end
      
      class QuestionOption < Base
        expose :name, :file, :file_url, :need_edit, :sort, :memo, :answer_type
      end
      
      class SimpleQuestion < Base
        expose :question, :answer_parse, :memo, :opened
        expose :right_answer, as: :answer
        expose :format_error_answer, as: :error_answer
        expose :source, :difficulty, :score, :exercise_count, :correct_count
        # expose :question_type, as: :type, using: API::V1::Entities::QuestionType
        expose :question_type, :question_type_id
      end
      
      class ExamQuestion < Base
        expose :question, using: API::V1::Entities::SimpleQuestion
        expose :score, :sort, :exam_id, :question_id
      end
      
      class Question < Base
        expose :question, :answer_parse, :memo, :opened
        expose :right_answer, as: :answer
        expose :format_error_answer, as: :error_answer
        expose :source, :difficulty, :score, :exercise_count, :correct_count
        # expose :question_type, as: :type, using: API::V1::Entities::QuestionType
        expose :question_type, :question_type_id
        expose :exam_points, as: :points, using: API::V1::Entities::ExamPoint
        expose :question_options, as: :options, using: API::V1::Entities::QuestionOption
        expose :exams, using: API::V1::Entities::SimpleExam
      end
      
      class Exam < SimpleExam
        expose :parent, using: API::V1::Entities::SimpleExam
        expose :children, using: API::V1::Entities::SimpleExam
        expose :exam_questions, as: :questions, using: API::V1::Entities::ExamQuestion
      end
      
      class SysClass < SimpleSysClass
        # expose :name, :memo, :students_count, :found_on
        expose :school_id
        expose :school_name do |model,opts|
          model.school.try(:name)
        end
        expose :wechat, :qq, :course_ids
        expose :courses, using: API::V1::Entities::Course
        expose :teacher_id
        expose :teacher_name do |model,opts|
          model.teacher.try(:name)
        end
        expose :students_count do |model,opts|
          model.students.size
        end
        expose :students, using: API::V1::Entities::SimpleStudent
      end
      
      class Assignment < Base
        expose :title, :body, :cover, :annex, :memo, :score, :teacher_comment
        expose :school_id, :cuc_id, :class_id, :course_id, :student_id, :teacher_id
        expose :cover_url, :course_order
        expose :annex_asset, using: API::V1::Entities::Attachment
        expose :teacher, using: API::V1::Entities::Teacher
        expose :school, using: API::V1::Entities::School
        expose :sys_class, using: API::V1::Entities::SimpleSysClass
        expose :course, using: API::V1::Entities::Course
        expose :course_assignment, using: API::V1::Entities::CourseUnitContent
        expose :student, using: API::V1::Entities::SimpleStudent
      end
      
      class Outcome < Base
        expose :name, :intro, :body, :student_id, :student_name, :memo, :sort, :opened, :score, :likes_count, :share_count, :comments_count, :view_count, :school_id, :school_name
        expose :cover, :cover_url
        expose :assignment, using: API::V1::Entities::Assignment
        expose :student, using: API::V1::Entities::Student
        expose :show_cases_assets, as: :show_cases, using: API::V1::Entities::Attachment
        expose :isRecommend, as: :is_recommend
        expose :recommend_at, format_with: :chinese_datetime
      end
      
      class SysAction < Base
        expose :name, :code
      end
      
      class SimpleSysFunc < Base
        expose :name, :code
        expose :actions, using: API::V1::Entities::SysAction
      end
      
      class SysFunc < Base
        expose :name, :code
        expose :sys_actions, as: :actions, using: API::V1::Entities::SysAction
        expose :selected_actions do |model,opts|
          model.selected_actions_for(opts)
        end
      end
      
      class Role < Base
        expose :name, :memo, :opened
        expose :sys_funcs, as: :permissions
      end
      
      class Article < Base
        expose :title, :body, :memo, :sort, :view_count, :likes_count, :share_count, :comments_count, :opened, :cover, :cover_url
        expose :tag_ids
        expose :tags, using: API::V1::Entities::SimpleTag
      end
      
      class Timetable < Base
        expose :begin_year_week, :end_year_week, :begin_time, :end_time, :repeat_type
        expose :format_week_days, as: :week_days
        expose :assoc_owner
        expose :school_id
        expose :school, using: API::V1::Entities::School
        expose :course_id, :course_type, :main_teacher_id, :assist_teacher_id, :classroom_id, :sort, :memo, :need_notify_teacher, :need_notify_student
        expose :course, using: API::V1::Entities::Course
        expose :main_teacher, using: API::V1::Entities::Teacher
        expose :assist_teacher, using: API::V1::Entities::Teacher
        expose :classroom, using: API::V1::Entities::Classroom
        expose :owner, using: API::V1::Entities::SysClass, if: proc { |o| o.owner_type == 'SysClass' }
        expose :owner, using: API::V1::Entities::Student, if: proc { |o| o.owner_type == 'Student' }
        expose :owner_type do |model,opts|
          model.owner_type
        end
      end
      
      class ClassSchedule < Base
        expose :plan_date, :begin_time, :end_time
        expose :assoc_owner
        expose :school_id
        expose :school, using: API::V1::Entities::School
        expose :course_id, :course_type, :main_teacher_id, :assist_teacher_id, :classroom_id, :sort, :memo, :need_notify_teacher, :need_notify_student
        expose :course, using: API::V1::Entities::Course
        expose :main_teacher, using: API::V1::Entities::Teacher
        expose :assist_teacher, using: API::V1::Entities::Teacher
        expose :classroom, using: API::V1::Entities::Classroom
        expose :owner, using: API::V1::Entities::SysClass, if: proc { |o| o.owner_type == 'SysClass' }
        expose :owner, using: API::V1::Entities::Student, if: proc { |o| o.owner_type == 'Student' }
        expose :owner_type do |model,opts|
          model.owner_type
        end
      end
      
      class ProductEarnConfig < Base
        expose :name, :l1_earn, :l2_earn, :l3_earn, :is_comm, :memo
      end
      
      class Product < Base
        expose :name, :body, :cover, :cover_url, :price, :m_price, :tag_type, :tag_type_name
        expose :memo, :opened, :orders_count, :view_count, :sort, :intro, :age_desc
        expose :earnable_type, :earnable_type_name
        expose :courses, using: API::V1::Entities::Course
        expose :categories, using: API::V1::Entities::SimpleCategory
        expose :course_ids, :free_course_ids, :earn_config_id, :category_ids
        expose :earn_config, using: API::V1::Entities::ProductEarnConfig
        expose :seller, using: API::V1::Entities::Teacher
      end
      
      class ShipAddress < Base
        expose :name, :mobile, :area, :address
      end
      
      class OrderSource < Base
        expose :name
      end
      
      class Order < Base
        expose :product, using: API::V1::Entities::Product
        expose :parent, using: API::V1::Entities::Parent
        expose :payed_at, as: :pay_time, format_with: :chinese_datetime
        expose :order_no
        expose :money, format_with: :rmb_format
        expose :discount_money, format_with: :rmb_format
        expose :l1_earn, format_with: :rmb_format
        expose :l2_earn, format_with: :rmb_format
        expose :l3_earn, format_with: :rmb_format
        expose :ship_address, using: API::V1::Entities::ShipAddress
        expose :source, using: API::V1::Entities::OrderSource
        expose :state, :state_name, :pay_type, :pay_type_name, :memo, :ship_address_id
        expose :can_cancel do |model,opts|
          model.can_cancel?
        end
        expose :can_confirm_pay do |model,opts|
          model.can_confirm_pay?
        end
      end
      
      class TradeLog < Base
        expose :uniq_id, as: :id, format_with: :null
        expose :title
        expose :money, format_with: :rmb_format
        expose :created_at, as: :time, format_with: :month_date_time
      end
      
      # 收益明细
      class EarnLog < Base
        expose :title
        expose :earn
        expose :unit
        expose :created_at, as: :time, format_with: :chinese_datetime
      end
      
      # 消息
      class Message < Base
        expose :title do |model, opts|
          model.title || '系统公告'
        end#, format_with: :null
        expose :content, as: :body
        expose :created_at, format_with: :chinese_datetime
      end
      
      # 提现
      class Withdraw < Base
        expose :bean, :fee
        expose :total_beans do |model, opts|
          model.bean + model.fee
        end
        expose :pay_type do |model, opts|
          if model.account_type == 1
            "微信提现"
          elsif model.account_type == 2
            "支付宝提现"
          else
            ""
          end
        end
        expose :state_info, as: :state
        expose :created_at, as: :time, format_with: :chinese_datetime
        # expose :user, using: API::V1::Entities::Author
      end
      
      class Banner < Base
        expose :uniq_id, as: :id
        expose :image do |model, opts|
          model.image.url(:large)
        end
        expose :link, format_with: :null, if: proc { |o| o.is_link? }
        # expose :loan_product, as: :loan, using: API::V1::Entities::LoanProduct, if: proc { |o| o.is_loan_product? }
        expose :page, using: API::V1::Entities::SimplePage, if: proc { |o| o.is_page? }
        expose :view_count, :click_count
      end
      
    end
  end
end
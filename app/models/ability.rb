class Ability
  include CanCan::Ability
  
  def initialize(user)
    can :manage, ActiveAdmin::Page, name: "Dashboard"#, namespace_name: :admin
    
    if user.super_admin?
      can :manage, :all
    else
      if user.admin?
        can :manage, :all
        cannot :manage, SiteConfig
        cannot :manage, PermissionResource
      else
        user.permissions.each do |permission|
          if permission.need_scope
            can permission.action.to_sym, (permission.func_class == 'all' ? permission.func_class.to_sym : permission.func_class.constantize), id: user.id
          else
            can permission.action.to_sym, (permission.func_class == 'all' ? permission.func_class.to_sym : permission.func_class.constantize)
          end
        end
        
        can :update, AdminUser do |admin|
          admin.id == user.id
        end
        # can :update, AdminUser, id: user.id
        
      end
      
      # cannot :destroy, :all
    end
    
    # if user.super_admin?
    #   can :manage, :all
    # elsif user.admin?
    #   can :manage, :all
    #
    #   cannot :manage, SiteConfig
    #   cannot :manage, PermissionItem
    #
    #   cannot :destroy, :all
    #   can :update, AdminUser do |admin|
    #     admin.id == user.id
    #   end
    #   can :destroy, Salary
    # else
    #   can :read, :all
    #   cannot :read, SiteConfig
    # end
    
    # if user.super_admin?
    #   can :manage, :all
    # elsif user.admin?
    #   can :manage, :all
    #   cannot :manage, SiteConfig
    #   cannot :manage, Admin, email: Setting.admin_emails
    #   cannot :destroy, :all
    # elsif user.site_editor?
    #   can :manage, :all
    #   cannot :manage, SiteConfig
    #   cannot :manage, Admin
    #   cannot :destroy, :all
    # elsif user.marketer?
    #   cannot :manage, :all
    #   can :read, :all
    #   cannot :read, SiteConfig
    #   cannot :read, Admin
    # elsif user.limited_user?
    #   cannot :manage, :all
    #   can :manage, ActiveAdmin::Page, name: "Dashboard"
    #   can :read, User
    #   can :read, UserSession
    #   can :read, WechatLocation
    #   can :read, UserChannel
    #   can :read, UserChannelLog
    #   can :read, Page
    #   can :read, Report
    #   can :read, Feedback
    #   # cannot :read, SiteConfig
    #   # cannot :read, Admin
    # end
  end
  
end
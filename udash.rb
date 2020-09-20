#!/usr/bin/env ruby

require 'bundler'
Bundler.setup
Bundler.require
require 'pp'
require 'json'

set :bind, '0.0.0.0'

def headers_for_containers
  %w(ID Names Image Status Command Networks Ports)
end

def headers_for_images
  %w(ID Repository Tag Size Containers)
end

def headers_for_volumes
  %w(Name Driver Links Mountpoint)
end

def containers
  `docker ps -a --format='{{json .}}'`.chomp.split("\n").map(&JSON.method(:parse))
end

def images
  `docker images --format='{{json .}}'`.chomp.split("\n").map(&JSON.method(:parse))
end

def volumes
  `docker volume ls --format='{{json .}}'`.chomp.split("\n").map(&JSON.method(:parse))
end


get '/' do
  haml :containers
end

get '/containers' do
  haml :containers
end

get '/images' do
  haml :images
end

get '/volumes' do
  haml :volumes
end

enable :inline_templates

__END__
@@layout
!!!
%html{:lang => "en"}
  %head
    %meta{:content => "text/html; charset=UTF-8", "http-equiv" => "Content-Type"}
    %meta{:charset => "utf-8"}/
    %meta{:content => "width=device-width, initial-scale=1, shrink-to-fit=no", :name => "viewport"}
    %link{:crossorigin => "anonymous", :href => "https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css", :integrity => "sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z", :rel => "stylesheet"}
    %title µDash — a tiny docker dashboard
  %body
    %container
      =yield
    %script{:crossorigin => "anonymous", :integrity => "sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj", :src => "https://code.jquery.com/jquery-3.5.1.slim.min.js"}
    %script{:crossorigin => "anonymous", :integrity => "sha384-9/reFTGAW83EW2RDu2S0VKaIzap3H66lZH81PoYlFhbGU+6BZp6G7niu735Sk7lN", :src => "https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"}
    %script{:crossorigin => "anonymous", :integrity => "sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV", :src => "https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"}

@@containers
%nav.navbar.navbar-expand-lg.navbar-light.bg-light
  %a.navbar-brand{:href => "#"} µDash
  %button.navbar-toggler{"aria-controls" => "navbarNavAltMarkup", "aria-expanded" => "false", "aria-label" => "Toggle navigation", "data-target" => "#navbarNavAltMarkup", "data-toggle" => "collapse", :type => "button"}
    %span.navbar-toggler-icon
  #navbarNavAltMarkup.collapse.navbar-collapse
    .navbar-nav
      %a.nav-link.active{:href => "/containers"}
        Containers
        %span.sr-only (current)
      %a.nav-link{:href => "/images"} Images
      %a.nav-link{:href => "/volumes"} Volumes
%h1 Active and inactive docker containers
%table{class: 'table table-hover', width: '100%'}
  %thead{class: "thead-light"}
    %tr
      - headers_for_containers.each do |header|
        %th= header
      %th Action
  %tbody
    - containers.each do |container|
      %tr
        - headers_for_containers.each do |name|
          %td= container[name]
        %td
          - if container['Status'] =~ /^Up /
            %form{ :action=>"/stop_container", :method=>"post"}
              %button.btn.btn-primary{:type => "submit"} Stop
          - else
            %form{ :action=>"/stop_container", :method=>"post"}
              %button.btn.btn-primary{:type => "submit"} Remove

@@images
%nav.navbar.navbar-expand-lg.navbar-light.bg-light
  %a.navbar-brand{:href => "#"} µDash
  %button.navbar-toggler{"aria-controls" => "navbarNavAltMarkup", "aria-expanded" => "false", "aria-label" => "Toggle navigation", "data-target" => "#navbarNavAltMarkup", "data-toggle" => "collapse", :type => "button"}
    %span.navbar-toggler-icon
  #navbarNavAltMarkup.collapse.navbar-collapse
    .navbar-nav
      %a.nav-link{:href => "/containers"} Containers
      %a.nav-link.active{:href => "/images"}
        Images
        %span.sr-only (current)
      %a.nav-link{:href => "/volumes"} Volumes
%h1 docker images
%table{class: 'table table-hover', width: '100%'}
  %thead{class: "thead-light"}
    %tr
      - headers_for_images.each do |header|
        %th= header
      %th Action
  %tbody
    - images.each do |image|
      %tr
        - headers_for_images.each do |name|
          %td= image[name]
        %td
          %form{ :action=>"/remove_image", :method=>"post"}
            %button.btn.btn-primary{:type => "submit"} Remove

@@volumes
%nav.navbar.navbar-expand-lg.navbar-light.bg-light
  %a.navbar-brand{:href => "#"} µDash
  %button.navbar-toggler{"aria-controls" => "navbarNavAltMarkup", "aria-expanded" => "false", "aria-label" => "Toggle navigation", "data-target" => "#navbarNavAltMarkup", "data-toggle" => "collapse", :type => "button"}
    %span.navbar-toggler-icon
  #navbarNavAltMarkup.collapse.navbar-collapse
    .navbar-nav
      %a.nav-link{:href => "/containers"} Containers
      %a.nav-link{:href => "/images"} Images
      %a.nav-link.active{:href => "/volumes"}
        Volumes
        %span.sr-only (current)
%h1 docker volumes
%table{class: 'table table-hover', width: '100%'}
  %thead{class: "thead-light"}
    %tr
      - headers_for_volumes.each do |header|
        %th= header
      %th Action
  %tbody
    - volumes.each do |volume|
      %tr
        - headers_for_volumes.each do |name|
          %td= volume[name]
        %td
          %form{ :action=>"/remove_volume", :method=>"post"}
            %button.btn.btn-primary{:type => "submit"} Remove

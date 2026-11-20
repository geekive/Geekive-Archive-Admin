package com.geekive.geekiveArchiveAdmin.configuration;

import java.util.Locale;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.support.ResourceBundleMessageSource;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.i18n.CookieLocaleResolver;

import com.geekive.geekiveArchiveAdmin.common.JwtUtil;
import com.geekive.geekiveArchiveAdmin.common.PropertyUtil;
import com.geekive.geekiveArchiveAdmin.interceptor.CommonDataInterceptor;
import com.geekive.geekiveArchiveAdmin.interceptor.LoginInterceptor;
import com.geekive.geekiveArchiveAdmin.mapper.service.CommonService;
import com.geekive.geekiveArchiveAdmin.mapper.service.LoginService;

@Component
public class WebMvcConfig implements WebMvcConfigurer{

	@Autowired
	private JwtUtil jwtUtil;
	
	@Autowired
	LoginService loginService;
	
	@Autowired
	private CommonService commonService;

	@Bean
	public LocaleResolver localeResolver() {
		CookieLocaleResolver resolver = new CookieLocaleResolver();
		resolver.setDefaultLocale(Locale.ENGLISH);
		resolver.setCookieName("lang");
		resolver.setCookiePath("/");
		resolver.setCookieMaxAge(60 * 60 * 24 * 30);
		resolver.setRejectInvalidCookies(false);
		return resolver;
	}

	@Bean
	public static MessageSource messageSource() {
		ResourceBundleMessageSource source = new ResourceBundleMessageSource();
		source.setBasename("messages");
		source.setDefaultEncoding("UTF-8");
		source.setDefaultLocale(Locale.ENGLISH);
		source.setFallbackToSystemLocale(false);
		return source;
	}

	@Override
	public void addInterceptors(InterceptorRegistry registry) {
		registry.addInterceptor(new LoginInterceptor(jwtUtil, loginService))
			.order(1)
			.addPathPatterns("/**")
			.excludePathPatterns("/login/**", "/css/**", "/js/**", "/upload/**", "/error", "/image/**");
		
		registry.addInterceptor(new CommonDataInterceptor(commonService))
			.order(2)
			.addPathPatterns("/**")
			.excludePathPatterns("/option/**", "/menu/**");
	}

	@Override
	public void addResourceHandlers(ResourceHandlerRegistry registry) {
		registry
			.addResourceHandler("/upload/**")
			.addResourceLocations("file:///" + PropertyUtil.getProperty("upload.path"));
	}
	
	
}

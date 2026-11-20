package com.geekive.geekiveArchiveAdmin.common;

import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Component;

@Component
public class MessageUtil {

	private static MessageSource messageSource;

	public MessageUtil(MessageSource messageSource) {
		MessageUtil.messageSource = messageSource;
	}

	public static String getMessage(String code) {
		return messageSource.getMessage(code, null, LocaleContextHolder.getLocale());
	}

	public static boolean isKorean() {
		return "ko".equals(LocaleContextHolder.getLocale().getLanguage());
	}
}

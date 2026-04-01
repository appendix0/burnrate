import 'package:flutter/material.dart';
import 'package:burnrate/core/constants/app_colors.dart';
import 'package:burnrate/data/models/service_type.dart';

class ServiceMeta {
  const ServiceMeta({
    required this.displayName,
    required this.shortName,
    required this.color,
    required this.icon,
    required this.description,
  });

  final String displayName;
  final String shortName;
  final Color color;
  final IconData icon;
  final String description;
}

const Map<ServiceType, ServiceMeta> kServiceMeta = {
  ServiceType.anthropic: ServiceMeta(
    displayName: 'Anthropic Claude',
    shortName: 'Claude',
    color: AppColors.anthropic,
    icon: Icons.auto_awesome,
    description: 'Claude API usage & token spend',
  ),
  ServiceType.openai: ServiceMeta(
    displayName: 'OpenAI',
    shortName: 'OpenAI',
    color: AppColors.openai,
    icon: Icons.psychology,
    description: 'GPT API usage & billing',
  ),
  ServiceType.gemini: ServiceMeta(
    displayName: 'Google Gemini',
    shortName: 'Gemini',
    color: AppColors.gemini,
    icon: Icons.scatter_plot,
    description: 'Gemini API token usage',
  ),
  ServiceType.aws: ServiceMeta(
    displayName: 'Amazon Web Services',
    shortName: 'AWS',
    color: AppColors.aws,
    icon: Icons.cloud,
    description: 'AWS Cost Explorer MTD spend',
  ),
  ServiceType.oracle: ServiceMeta(
    displayName: 'Oracle Cloud',
    shortName: 'OCI',
    color: AppColors.oracle,
    icon: Icons.storage,
    description: 'OCI Usage API MTD costs',
  ),
};

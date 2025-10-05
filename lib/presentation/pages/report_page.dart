import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/interview_service.dart';
import '../../core/di/providers.dart';

class ReportPage extends ConsumerStatefulWidget {
  final String? conversationId;
  
  const ReportPage({super.key, this.conversationId});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? _suggestions;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadReportData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  Future<void> _loadReportData() async {
    if (widget.conversationId == null) {
      setState(() {
        _error = 'No conversation ID provided';
        _isLoading = false;
      });
      return;
    }

    try {
      final interviewService = await ref.read(interviewServiceProvider.future);
      
      // Get analytics and suggestions from backend
      final analyticsResponse = await interviewService.getUserAnalytics();
      
      setState(() {
        _analytics = analyticsResponse.analytics?.isNotEmpty == true 
            ? analyticsResponse.analytics!.first 
            : null;
        _suggestions = {
          'positive_points': analyticsResponse.positivePoints ?? [],
          'negative_points': analyticsResponse.negativePoints ?? [],
          'improvement_suggestions': analyticsResponse.improvementSuggestions ?? [],
          'structured_thinking_analysis': analyticsResponse.structuredThinkingAnalysis ?? '',
          'communication_assessment': analyticsResponse.communicationAssessment ?? '',
          'behavioral_competencies': analyticsResponse.behavioralCompetencies ?? [],
          'confidence_and_composure_analysis': analyticsResponse.confidenceAndComposureAnalysis ?? '',
          'storytelling_effectiveness': analyticsResponse.storytellingEffectiveness ?? '',
          'engagement_and_enthusiasm': analyticsResponse.engagementAndEnthusiasm ?? '',
          'psychological_improvement_tips': analyticsResponse.psychologicalImprovementTips ?? [],
          'rating': analyticsResponse.rating ?? 0,
          'summary': analyticsResponse.summary ?? '',
        };
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _error = 'Failed to load report data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3282B8)),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[400],
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.go('/dashboard'),
                        child: const Text('Back to Dashboard'),
                      ),
                    ],
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 32),
                            _buildOverallScore(),
                            const SizedBox(height: 24),
                            _buildAnalyticsCharts(),
                            const SizedBox(height: 24),
                            _buildFeedbackSections(),
                            const SizedBox(height: 32),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interview Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Conversation ID: ${widget.conversationId?.substring(0, 8)}...',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildOverallScore() {
    final rating = _suggestions?['rating'] ?? 0;
    final summary = _suggestions?['summary'] ?? '';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getScoreColor(rating.toDouble()).withOpacity(0.2),
            _getScoreColor(rating.toDouble()).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getScoreColor(rating.toDouble()).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Performance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getScoreColor(rating.toDouble()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$rating/10',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              summary,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyticsCharts() {
    if (_analytics == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Analytics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: RadarChart(
            RadarChartData(
              radarTouchData: RadarTouchData(enabled: false),
              dataSets: [
                RadarDataSet(
                  fillColor: const Color(0xFF3282B8).withOpacity(0.2),
                  borderColor: const Color(0xFF3282B8),
                  entryRadius: 3,
                  dataEntries: [
                    RadarEntry(value: (_analytics!['confidence'] ?? 0.0) * 10),
                    RadarEntry(value: (_analytics!['fluency'] ?? 0.0) * 10),
                    RadarEntry(value: (_analytics!['clarity'] ?? 0.0) * 10),
                    RadarEntry(value: (_analytics!['storytelling'] ?? 0.0) * 10),
                    RadarEntry(value: (_analytics!['persuasiveness'] ?? 0.0) * 10),
                    RadarEntry(value: (_analytics!['structured_thinking'] ?? 0.0) * 10),
                  ],
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: const BorderSide(color: Colors.transparent),
              titlePositionPercentageOffset: 0.2,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              getTitle: (index, angle) {
                switch (index) {
                  case 0:
                    return RadarChartTitle(text: 'Confidence');
                  case 1:
                    return RadarChartTitle(text: 'Fluency');
                  case 2:
                    return RadarChartTitle(text: 'Clarity');
                  case 3:
                    return RadarChartTitle(text: 'Storytelling');
                  case 4:
                    return RadarChartTitle(text: 'Persuasiveness');
                  case 5:
                    return RadarChartTitle(text: 'Structured Thinking');
                  default:
                    return const RadarChartTitle(text: '');
                }
              },
              tickCount: 5,
              ticksTextStyle: const TextStyle(
                color: Colors.transparent,
                fontSize: 10,
              ),
              tickBorderData: const BorderSide(color: Colors.grey, width: 1),
              gridBorderData: const BorderSide(color: Colors.grey, width: 1),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildMetricsGrid(),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    if (_analytics == null) return const SizedBox.shrink();
    
    final metrics = [
      {'label': 'Tone', 'value': _analytics!['tone'] ?? 'N/A', 'icon': Icons.mood},
      {'label': 'Repetition', 'value': '${((_analytics!['repetition'] ?? 0.0) * 100).toInt()}%', 'icon': Icons.repeat},
      {'label': 'Fumblings', 'value': '${((_analytics!['fumblings'] ?? 0.0) * 100).toInt()}%', 'icon': Icons.warning},
      {'label': 'Hesitations', 'value': '${((_analytics!['hesitations'] ?? 0.0) * 100).toInt()}%', 'icon': Icons.pause},
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                metric['icon'] as IconData,
                color: const Color(0xFF3282B8),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      metric['label'] as String,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      metric['value'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedbackSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeedbackSection(
          'Strengths',
          _suggestions?['positive_points'] ?? [],
          Colors.green,
          Icons.check_circle,
        ),
        const SizedBox(height: 16),
        _buildFeedbackSection(
          'Areas for Improvement',
          _suggestions?['negative_points'] ?? [],
          Colors.orange,
          Icons.warning,
        ),
        const SizedBox(height: 16),
        _buildFeedbackSection(
          'Improvement Suggestions',
          _suggestions?['improvement_suggestions'] ?? [],
          const Color(0xFF3282B8),
          Icons.lightbulb,
        ),
        const SizedBox(height: 16),
        _buildFeedbackSection(
          'Psychological Tips',
          _suggestions?['psychological_improvement_tips'] ?? [],
          Colors.purple,
          Icons.psychology,
        ),
      ],
    );
  }

  Widget _buildFeedbackSection(String title, List<dynamic> items, Color color, IconData icon) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item.toString(),
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              context.go('/interview');
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Take Another Interview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3282B8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              context.go('/dashboard');
            },
            icon: const Icon(Icons.dashboard, color: Color(0xFF3282B8)),
            label: const Text(
              'Back to Dashboard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3282B8),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF3282B8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return const Color(0xFF10B981); // Green
    if (score >= 6.0) return const Color(0xFFF59E0B); // Yellow
    if (score >= 4.0) return const Color(0xFFEF4444); // Red
    return Colors.grey; // Very low score
  }
}

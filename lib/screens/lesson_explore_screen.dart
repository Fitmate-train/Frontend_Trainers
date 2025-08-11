import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 수업 둘러보기 + (트레이너용) 수업 개설하기 위저드 탭 화면
class LessonExploreScreen extends StatelessWidget {
  const LessonExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('수업 둘러보기'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '둘러보기', icon: Icon(Icons.search)),
              Tab(text: '개설하기', icon: Icon(Icons.add_circle_outline)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ExploreTab(),
            _ClassCreateWizard(), // 여기서 위저드가 바로 동작
          ],
        ),
      ),
    );
  }
}

/// -------------------- Tab 1: 둘러보기 (임시 스텁) --------------------
class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: '운동 / 지역 / 트레이너를 검색해 보세요',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('둘러보기 화면은 준비 중입니다.'),
            subtitle: Text('필터/리스트/상세와 연동 예정'),
          ),
        ),
      ],
    );
  }
}

/// -------------------- Tab 2: 수업 개설 위저드 --------------------
class _ClassCreateWizard extends StatefulWidget {
  const _ClassCreateWizard();

  @override
  State<_ClassCreateWizard> createState() => _ClassCreateWizardState();
}

class _ClassCreateWizardState extends State<_ClassCreateWizard> {
  // ---- 상태 ----
  int step = 0;
  final _services = const ['퍼스널트레이닝(PT)', '필라테스', '요가', '스트레칭'];
  String? service;

  final _ptGoals = const [
    '근력 강화',
    '체중 증가',
    '체력 증진',
    '체형 교정',
    '재활/통증 케어',
    '바디프로필',
  ];
  final Set<String> goals = {};

  final _places = const ['트레이너 센터', '회원 방문', '온라인'];
  String? place;

  final Set<String> days = {}; // 월~일
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final durationCtrl = TextEditingController(); // 분
  final priceCtrl = TextEditingController(); // 원

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  // ---- 유틸 ----
  double get progress => (step / 6.0).clamp(0, 1);
  String _fmtTime(TimeOfDay t) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat('a h:mm', 'ko_KR').format(dt);
  }

  bool get canNext {
    switch (step) {
      case 0:
        return service != null;
      case 1:
        return service != '퍼스널트레이닝(PT)' || goals.isNotEmpty;
      case 2:
        return place != null;
      case 3:
        return days.isNotEmpty && startTime != null && endTime != null;
      case 4:
        final d = int.tryParse(durationCtrl.text);
        final p = int.tryParse(priceCtrl.text);
        return (d != null && d > 0) && (p != null && p > 0);
      case 5:
        return titleCtrl.text.trim().isNotEmpty &&
            descCtrl.text.trim().length >= 10;
      default:
        return false;
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final base = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: base);
    if (picked != null) {
      setState(() {
        if (isStart)
          startTime = picked;
        else
          endTime = picked;
      });
    }
  }

  void _submit() {
    // TODO: 여기서 서버로 전송 (REST/Mongo)
    debugPrint(
      'CREATE CLASS >>> '
      'service=$service, goals=$goals, place=$place, days=$days, '
      'time=${startTime?.format(context)}~${endTime?.format(context)}, '
      'duration=${durationCtrl.text}, price=${priceCtrl.text}, '
      'title=${titleCtrl.text}, desc=${descCtrl.text.length} chars',
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('수업이 등록되었어요!')));
    // 이 위저드는 탭 안에서 동작하므로 pop 대신 초기화
    setState(() {
      step = 0;
      service = null;
      goals.clear();
      place = null;
      days.clear();
      startTime = endTime = null;
      durationCtrl.clear();
      priceCtrl.clear();
      titleCtrl.clear();
      descCtrl.clear();
    });
  }

  @override
  void dispose() {
    durationCtrl.dispose();
    priceCtrl.dispose();
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF6C4EF6);

    return Column(
      children: [
        // 진행바
        LinearProgressIndicator(value: progress, minHeight: 4, color: purple),
        const SizedBox(height: 8),

        // 채팅 리스트
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              if (step >= 0) ...[
                _Q('어떤 종류의 수업인가요?'),
                _OptionList.single(
                  options: _services,
                  value: service,
                  onChanged: (v) => setState(() => service = v),
                ),
              ],
              if (service == '퍼스널트레이닝(PT)') ...[
                const SizedBox(height: 12),
                _Q('PT 목적은 무엇인가요? (복수 선택)'),
                _OptionList.multi(
                  options: _ptGoals,
                  selected: goals,
                  onToggle:
                      (v) => setState(() {
                        if (goals.contains(v))
                          goals.remove(v);
                        else
                          goals.add(v);
                      }),
                ),
              ],
              if (step >= 2) ...[
                const SizedBox(height: 12),
                _Q('수업 장소를 알려주세요.'),
                _OptionList.single(
                  options: _places,
                  value: place,
                  onChanged: (v) => setState(() => place = v),
                ),
              ],
              if (step >= 3) ...[
                const SizedBox(height: 12),
                _Q('가능한 요일과 시간을 선택해주세요.'),
                _DaysPicker(
                  selected: days,
                  onChanged:
                      (d) => setState(() {
                        if (days.contains(d))
                          days.remove(d);
                        else
                          days.add(d);
                      }),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickTime(true),
                        child: Text(
                          startTime == null ? '시작 시간' : _fmtTime(startTime!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickTime(false),
                        child: Text(
                          endTime == null ? '종료 시간' : _fmtTime(endTime!),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (step >= 4) ...[
                const SizedBox(height: 12),
                _Q('1회 수업 시간과 가격을 입력해주세요.'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: durationCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '수업 시간(분)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '1회 가격(원)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (step >= 5) ...[
                const SizedBox(height: 12),
                _Q('수업 제목과 소개를 작성해주세요.'),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: '제목',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: '소개 (10자 이상)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              if (step == 6) ...[
                const SizedBox(height: 12),
                _Q('미리보기'),
                _Preview(
                  service: service!,
                  goals: goals.toList(),
                  place: place!,
                  days:
                      days.toList()
                        ..sort((a, b) => _dayIndex(a).compareTo(_dayIndex(b))),
                  time: '${_fmtTime(startTime!)} ~ ${_fmtTime(endTime!)}',
                  duration: '${durationCtrl.text}분',
                  price: NumberFormat.currency(
                    locale: 'ko_KR',
                    symbol: '₩',
                    decimalDigits: 0,
                  ).format(int.parse(priceCtrl.text)),
                  title: titleCtrl.text,
                  desc: descCtrl.text,
                ),
              ],
            ],
          ),
        ),

        // 하단 네비게이션 바
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
            ],
          ),
          child: Row(
            children: [
              if (step > 0)
                OutlinedButton.icon(
                  onPressed: () => setState(() => step -= 1),
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('이전'),
                ),
              if (step == 0) const SizedBox.shrink(),
              const Spacer(),
              FilledButton(
                onPressed:
                    !canNext
                        ? null
                        : () {
                          if (step < 5) {
                            setState(() => step += 1);
                          } else if (step == 5) {
                            setState(() => step = 6); // 미리보기
                          } else {
                            _submit(); // 제출
                          }
                        },
                child: Text(step < 5 ? '다음' : (step == 5 ? '미리보기' : '등록하기')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static int _dayIndex(String d) {
    const order = ['월', '화', '수', '목', '금', '토', '일'];
    return order.indexOf(d);
  }
}

/// ---------- 공용 UI 컴포넌트 ----------
class _Q extends StatelessWidget {
  final String text;
  const _Q(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _OptionList extends StatelessWidget {
  // single
  const _OptionList.single({
    required this.options,
    required this.value,
    required this.onChanged,
  }) : selected = null,
       onToggle = null,
       multi = false;

  // multi
  const _OptionList.multi({
    required this.options,
    required this.selected,
    required this.onToggle,
  }) : value = null,
       onChanged = null,
       multi = true;

  final List<String> options;
  final String? value;
  final void Function(String v)? onChanged;

  final Set<String>? selected;
  final void Function(String v)? onToggle;

  final bool multi;

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          options.map((o) {
            final active = multi ? (selected!.contains(o)) : (value == o);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  if (multi) {
                    onToggle!(o);
                  } else {
                    onChanged!(o);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          active
                              ? const Color(0xFF6C4EF6)
                              : const Color(0xFFE3E5EA),
                    ),
                    color: active ? const Color(0xFFEDE9FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        active
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: active ? const Color(0xFF6C4EF6) : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(o)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _DaysPicker extends StatelessWidget {
  final Set<String> selected;
  final void Function(String) onChanged;
  const _DaysPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          days.map((d) {
            final active = selected.contains(d);
            return ChoiceChip(
              label: Text(d),
              selected: active,
              onSelected: (_) => onChanged(d),
            );
          }).toList(),
    );
  }
}

class _Preview extends StatelessWidget {
  final String service;
  final List<String> goals;
  final String place;
  final List<String> days;
  final String time;
  final String duration;
  final String price;
  final String title;
  final String desc;

  const _Preview({
    required this.service,
    required this.goals,
    required this.place,
    required this.days,
    required this.time,
    required this.duration,
    required this.price,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    Widget row(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(k, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(v)),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          row('수업', service),
          if (goals.isNotEmpty) row('목적', goals.join(', ')),
          row('장소', place),
          row('요일/시간', '${days.join(', ')}  $time'),
          row('시간/가격', '$duration · $price'),
          const Divider(),
          row('제목', title),
          row('소개', desc),
        ],
      ),
    );
  }
}

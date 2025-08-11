import 'package:flutter/material.dart';
import '../models/trainer_model.dart';
import 'package:carousel_slider/carousel_slider.dart';

class LessonDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Trainer trainer =
        ModalRoute.of(context)!.settings.arguments as Trainer;

    return Scaffold(
      appBar: AppBar(title: Text('${trainer.name} 선생님')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(height: 200, viewportFraction: 1.0),
              items:
                  trainer.imageUrls.map((url) {
                    return Image.asset(
                      url,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trainer.name,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 4),
                      Text('${trainer.reviewCount}개의 후기'),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('전문 분야: ${trainer.intro}'),
                  SizedBox(height: 8),
                  Text('수업 위치: ${trainer.location}'),
                  SizedBox(height: 8),
                  Text(
                    '1회 체험가: ${trainer.firstLessonRate.toStringAsFixed(0)}원',
                  ),
                  Divider(height: 32),
                  Text(
                    '수업 설명',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '이 수업은 복부 중심 운동과 체형 교정을 목표로 하며, '
                    '초보자도 쉽게 따라올 수 있도록 구성되어 있습니다. '
                    '트레이너가 1:1로 집중 케어를 해드려요!',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/lesson_chat', arguments: trainer);
          },
          child: Text('예약 요청하기'),
          style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
        ),
      ),
    );
  }
}

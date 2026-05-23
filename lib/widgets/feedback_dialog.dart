import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> showFeedbackDialog({
  required BuildContext context,
  required String username,
  required VoidCallback onSuccess,
}) async {
  final controller = TextEditingController();
  final scrollController = ScrollController();

  bool sending = false;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final isDark =
              Theme.of(context).brightness ==
                  Brightness.dark;

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 20,
            ),
            child: Container(
              height: 700,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: isDark
                    ? const Color(0xff111827)
                    : Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 30,
                    color: Colors.black.withValues(
                      alpha: 0.18,
                    ),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff7C3AED),
                          Color(0xff2563EB),
                        ],
                      ),
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              Colors.white24,
                          child: Icon(
                            Icons.support_agent,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: const [
                              Text(
                                "Support Chat",
                                style: TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Admin replies here",
                                style: TextStyle(
                                  color:
                                      Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              Navigator.pop(
                                  dialogContext),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: Supabase.instance.client
                          .from('feedback')
                          .stream(
                            primaryKey: ['id'],
                          )
                          .eq('user', username)
                          .order(
                            'time',
                            ascending: true,
                          ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child:
                                CircularProgressIndicator(),
                          );
                        }

                        final messages =
                            snapshot.data!;

                        WidgetsBinding.instance
                            .addPostFrameCallback((_) {
                          if (scrollController
                              .hasClients) {
                            scrollController
                                .jumpTo(
                              scrollController
                                  .position
                                  .maxScrollExtent,
                            );
                          }
                        });

                        if (messages.isEmpty) {
                          return Center(
                            child: Text(
                              "Start a conversation",
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller:
                              scrollController,
                          padding:
                              const EdgeInsets.all(
                                  16),
                          itemCount:
                              messages.length,
                          itemBuilder:
                              (_, index) {
                            final item =
                                messages[index];

                            final userMsg =
                                item['message'] ??
                                    "";

                            final adminReply =
                                item['reply'] ??
                                    "";

                            final time =
                                item['time']
                                        ?.toString() ??
                                    "";

                            return Column(
                              children: [
                                Align(
                                  alignment:
                                      Alignment
                                          .centerRight,
                                  child:
                                      _chatBubble(
                                    text: userMsg,
                                    time: time,
                                    isUser: true,
                                    isDark:
                                        isDark,
                                  ),
                                ),
                                                                if (adminReply
                                    .toString()
                                    .isNotEmpty)
                                  Align(
                                    alignment:
                                        Alignment
                                            .centerLeft,
                                    child:
                                        _chatBubble(
                                      text:
                                          adminReply,
                                      time: time,
                                      isUser:
                                          false,
                                      isDark:
                                          isDark,
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(
                              0xff1F2937)
                          : const Color(
                              0xffF3F4F6),
                      borderRadius:
                          const BorderRadius.vertical(
                        bottom:
                            Radius.circular(28),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller:
                                controller,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            decoration:
                                InputDecoration(
                              hintText:
                                  "Type message...",
                              hintStyle:
                                  TextStyle(
                                color: isDark
                                    ? Colors
                                        .white54
                                    : Colors
                                        .black45,
                              ),
                              filled: true,
                              fillColor:
                                  isDark
                                      ? Colors
                                          .white10
                                      : Colors
                                          .white,
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        20),
                                borderSide:
                                    BorderSide.none,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                horizontal:
                                    16,
                                vertical:
                                    14,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        GestureDetector(
                          onTap: sending
                              ? null
                              : () async {
                                  if (controller
                                      .text
                                      .trim()
                                      .isEmpty) {
                                    return;
                                  }

                                  setState(() {
                                    sending =
                                        true;
                                  });

                                  try {
                                    await Supabase
                                        .instance
                                        .client
                                        .from(
                                            'feedback')
                                        .insert({
                                      'user':
                                          username,
                                      'message':
                                          controller
                                              .text
                                              .trim(),
                                      'reply': '',
                                      'status':
                                          'pending',
                                      'time': DateTime
                                              .now()
                                          .toIso8601String(),
                                    });

                                    controller
                                        .clear();

                                    onSuccess();
                                  } catch (e) {
                                    debugPrint(
                                        "$e");
                                  }

                                  setState(() {
                                    sending =
                                        false;
                                  });
                                },
                          child: Container(
                            padding:
                                const EdgeInsets.all(
                                    16),
                            decoration:
                                const BoxDecoration(
                              gradient:
                                  LinearGradient(
                                colors: [
                                  Color(
                                      0xff7C3AED),
                                  Color(
                                      0xff2563EB),
                                ],
                              ),
                              shape:
                                  BoxShape.circle,
                            ),
                            child: sending
                                ? const SizedBox(
                                    width:
                                        20,
                                    height:
                                        20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                      color: Colors
                                          .white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.send,
                                    color: Colors
                                        .white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _chatBubble({
  required String text,
  required String time,
  required bool isUser,
  required bool isDark,
}) {
  return Container(
    margin: const EdgeInsets.only(
      bottom: 12,
    ),
    padding: const EdgeInsets.all(14),
    constraints: const BoxConstraints(
      maxWidth: 280,
    ),
    decoration: BoxDecoration(
      gradient: isUser
          ? const LinearGradient(
              colors: [
                Color(0xff7C3AED),
                Color(0xff2563EB),
              ],
            )
          : null,
      color: isUser
          ? null
          : (isDark
              ? Colors.white10
              : Colors.grey.shade200),
      borderRadius: BorderRadius.circular(
          20),
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        if (!isUser)
          const Text(
            "Admin",
            style: TextStyle(
              color: Colors.cyan,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

        if (!isUser)
          const SizedBox(height: 6),

        Text(
          text,
          style: TextStyle(
            color: isUser
                ? Colors.white
                : (isDark
                    ? Colors.white
                    : Colors.black87),
            height: 1.4,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          time.length > 16
              ? time.substring(0, 16)
              : time,
          style: TextStyle(
            fontSize: 11,
            color: isUser
                ? Colors.white70
                : Colors.grey,
          ),
        ),
      ],
    ),
  );
}
export interface Comment {
  id: number
  author: string
  content: string
  timestamp: string
  replies: Comment[]
}

export const commentList = [
  {
    id: 1,
    author: '用户1',
    content: '这是一条评论',
    timestamp: new Date(Date.now() - 86400000).toISOString(),
    replies: []
  },
  {
    id: 2,
    author: '用户2',
    content: '这是另一条评论',
    timestamp: new Date(Date.now() - 3600000).toISOString(),
    replies: [
      {
        id: 101,
        author: '用户1',
        content: '感谢回复',
        timestamp: new Date(Date.now() - 1800000).toISOString(),
        replies: []
      }
    ]
  }
] as Comment[]

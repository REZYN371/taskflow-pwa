export type Priority = 'Kritis' | 'Tinggi' | 'Sedang' | 'Rendah';
export type TaskStatus = 'Belum dimulai' | 'Sedang dikerjakan' | 'Ditunda' | 'Selesai';
export type Task = { id:string; title:string; category:string; due:string; dueTime:string; duration:number; difficulty:number; importance:number; impact:number; status:TaskStatus; priority:Priority; scheduled?:string; description?:string; createdAt:string };
export type ScheduleItem = { id:string; day:number; title:string; start:string; end:string; fixed:boolean; category:string };
